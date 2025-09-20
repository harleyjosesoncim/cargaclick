# frozen_string_literal: true

class PagamentosController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[webhook ping]
  before_action :set_pagamento, only: [:show, :cancelar]

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

  def calcular_valor_final(frete, cliente)
    # lógica de cálculo → substitua pela regra do seu negócio
    frete.valor_base
  end
end
