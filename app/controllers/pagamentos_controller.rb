# frozen_string_literal: true

class PagamentosController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[webhook ping]
  before_action :set_pagamento, only: %i[show update cancelar liberar]

  # ===============================================================
  # LISTAGEM / VISUALIZAÇÃO
  # ===============================================================
  def index
    @pagamentos = Pagamento.includes(:frete, :transportador, :cliente).recentes
  end

  def show; end

  # ===============================================================
  # CHECKOUT
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

    # Mantém compatibilidade com colunas/aliases
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
  # ATUALIZAÇÃO DE STATUS (UI/Turbo)
  # ===============================================================
  # PATCH /pagamentos/:id?status=escrow|cancelado|confirmado|estornado
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
  # POST /pagamentos/:id/liberar
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
  # CALLBACKS DO GATEWAY
  # ===============================================================
  def retorno
    PagamentoPixService.new.retorno(params)
    redirect_to root_path, notice: "Pagamento processado. Se aprovado, os contatos foram liberados."
  end

  def webhook
    PagamentoPixService.new.webhook(params)
    head :ok
  end

  def ping
    head :ok
  end

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
    return frete.transportador if frete.respond_to?(:transportador) && frete.transportador.present?
    nil
  end

  def calcular_valor_final(frete, _cliente)
    # Usa o valor já consolidado no Frete (valor_final/estimado).
    frete.valor_total.to_d
  end

  def autorizado_para_liberar?(pagamento)
    # Admin pode liberar sempre
    if respond_to?(:admin_user_signed_in?) && admin_user_signed_in?
      return true
    end

    # Cliente dono do frete pode liberar
    if respond_to?(:cliente_signed_in?) && cliente_signed_in?
      return pagamento.cliente_id.present? && current_cliente.id == pagamento.cliente_id
    end

    false
  end
end
