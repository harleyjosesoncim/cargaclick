# frozen_string_literal: true

class PagamentosController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[webhook ping pix_efi]
  before_action :set_pagamento, only: %i[show update cancelar liberar]

  # ===============================================================
  # LISTAGEM / VISUALIZAÇÃO
  # ===============================================================
  def index
    @pagamentos = Pagamento.includes(:frete, :transportador, :cliente).recentes
  end

  def show; end

  # ===============================================================
  # CHECKOUT (LEGADO / ATUAL)
  # ===============================================================
  # POST /pagamentos/checkout?frete_id=123
  def checkout
    frete = Frete.find(params[:frete_id])
    cliente = identificar_cliente(frete)
    transportador = identificar_transportador(frete)

    unless cliente && transportador
      return render json: { error: "Cliente ou transportador não definido" }, status: :unprocessable_entity
    end

    pagamento = Pagamento.find_or_initialize_by(frete: frete, transportador: transportador)
    pagamento.cliente = cliente

    pagamento.valor_total = calcular_valor_final(frete, cliente)
    pagamento.comissao_cargaclick ||= 0
    pagamento.valor_liquido ||= pagamento.valor_total
    pagamento.status ||= "pendente"
    pagamento.save!

    service = PagamentoPixService.new

    result =
      if cliente.respond_to?(:assinante?) && cliente.assinante?
        service.checkout_assinante(frete, cliente, transportador, pagamento)
      elsif cliente.respond_to?(:avulso?) && cliente.avulso?
        service.checkout_avulso(frete, cliente, transportador, pagamento)
      else
        service.checkout_pf(frete, cliente, transportador, pagamento)
      end

    if result.success?
      render json: result.data.merge(
        frete_id: frete.id,
        cliente_id: cliente.id,
        transportador_id: transportador.id,
        pagamento_id: pagamento.id
      )
    else
      render json: { error: result.error }, status: :unprocessable_entity
    end
  end

  # ===============================================================
  # ATUALIZAÇÃO DE STATUS
  # ===============================================================
  def update
    status = params[:status].to_s

    case status
    when "escrow"
      @pagamento.colocar_em_escrow! if @pagamento.respond_to?(:colocar_em_escrow!)
    when "confirmado"
      @pagamento.confirmar!
    when "cancelado"
      return redirect_to(@pagamento, alert: "⚠️ Só é possível cancelar quando pendente.") unless @pagamento.pendente?
      @pagamento.cancelar!
    when "estornado"
      @pagamento.estornar! if @pagamento.respond_to?(:estornar!)
    else
      return respond_to do |format|
        format.turbo_stream { render :update, status: :unprocessable_entity }
        format.html { redirect_to @pagamento, alert: "Status inválido." }
        format.json { render json: { error: "Status inválido" }, status: :unprocessable_entity }
      end
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @pagamento, notice: "✅ Status atualizado." }
      format.json { render json: { ok: true, status: @pagamento.status } }
    end
  end

  # ===============================================================
  # CANCELAR
  # ===============================================================
  def cancelar
    if @pagamento.pendente?
      @pagamento.cancelar!
      redirect_to @pagamento, notice: "❌ Pagamento cancelado com sucesso."
    else
      redirect_to @pagamento, alert: "⚠️ Não é possível cancelar um pagamento #{@pagamento.status}."
    end
  end

  # ===============================================================
  # ESCROW / REPASSE
  # ===============================================================
  def liberar
    unless autorizado_para_liberar?(@pagamento)
      return respond_to do |format|
        format.html { redirect_to @pagamento, alert: "⚠️ Você não tem permissão para liberar este repasse." }
        format.json { render json: { error: "forbidden" }, status: :forbidden }
      end
    end

    actor = (respond_to?(:current_admin_user) && current_admin_user) ||
            (respond_to?(:current_cliente) && current_cliente)

    result = Pagamentos::EscrowService.new.liberar!(@pagamento, actor: actor)

    if result.success?
      respond_to do |format|
        format.turbo_stream { render :update }
        format.html { redirect_to @pagamento, notice: "✅ Repasse liberado com sucesso." }
        format.json { render json: { ok: true, status: @pagamento.status, payout_txid: @pagamento.payout_txid } }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :update }
        format.html { redirect_to @pagamento, alert: "❌ Falha ao liberar repasse: #{result.error}" }
        format.json { render json: { error: result.error }, status: :unprocessable_entity }
      end
    end
  end

  # ===============================================================
  # CALLBACKS LEGADOS
  # ===============================================================
  def retorno
    PagamentoPixService.new.retorno(params)
    redirect_to root_path, notice: "Pagamento processado."
  end

  def webhook
    PagamentoPixService.new.webhook(params)
    head :ok
  end

  def ping
    head :ok
  end

  # ===============================================================
  # PIX EFI (NOVO – ISOLADO – SEM IMPACTO NO CHECKOUT ATUAL)
  # ===============================================================
  # POST /pagamentos/pix_efi?frete_id=123
  def pix_efi
    frete = Frete.find(params[:frete_id])

    service = Pix::EfiService.new(frete: frete)
    service.criar_cobranca!

    render json: {
      success: true,
      frete_id: frete.id,
      pix: {
        txid:       frete.pix_txid,
        qr_code:    frete.pix_qr_code,
        copia_cola: frete.pix_copia_cola,
        status:     frete.status_pagamento
      }
    }
  rescue Pix::EfiService::Error => e
    render json: { success: false, error: e.message }, status: :unprocessable_entity
  rescue => e
    Rails.logger.error("[PIX][EFI][PAGAMENTOS] #{e.class} - #{e.message}")
    render json: { success: false, error: "Erro interno ao gerar Pix" }, status: :internal_server_error
  end

  # ===============================================================
  # PRIVATES
  # ===============================================================
  private

  def set_pagamento
    @pagamento = Pagamento.find(params[:id])
  end

  def identificar_cliente(frete)
    return frete.cliente if frete.respond_to?(:cliente) && frete.cliente.present?
    return frete.cliente_cpf if frete.respond_to?(:cliente_cpf) && frete.cliente_cpf.present?
    return frete.cliente_cnpj if frete.respond_to?(:cliente_cnpj) && frete.cliente_cnpj.present?
    nil
  end

  def identificar_transportador(frete)
    frete.transportador if frete.respond_to?(:transportador)
  end

  def calcular_valor_final(frete, _cliente)
    frete.valor_final || frete.valor_estimado
  end

  def autorizado_para_liberar?(pagamento)
    return true if respond_to?(:admin_user_signed_in?) && admin_user_signed_in?

    if respond_to?(:cliente_signed_in?) && cliente_signed_in?
      pagamento.cliente_id.present? && current_cliente.id == pagamento.cliente_id
    else
      false
    end
  end
end
