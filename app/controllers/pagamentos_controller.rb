# app/controllers/pagamentos_controller.rb
# frozen_string_literal: true

class PagamentosController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[webhook ping]

  # POST /pagamentos/checkout?frete_id=123
  def checkout
    frete = Frete.find(params[:frete_id])
    cliente = identificar_cliente(frete)
    transportador = identificar_transportador(frete)

    unless cliente && transportador
      return render json: { error: "Cliente ou transportador não definido" }, status: :unprocessable_entity
    end

    # Cria/atualiza pagamento vinculado ao frete
    pagamento = Pagamento.find_or_initialize_by(frete: frete, transportador: transportador)
    pagamento.cliente = cliente
    pagamento.valor_total = calcular_valor_final(frete, cliente)
    pagamento.comissao_cargaclick ||= 0
    pagamento.valor_liquido ||= pagamento.valor_total
    pagamento.status ||= "pendente"
    pagamento.save!

    # Decide modelo de checkout conforme tipo de cliente
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

  # Callback de retorno simples (usuário redirecionado após pagamento)
  def retorno
    PagamentoPixService.new.retorno(params)
    redirect_to root_path, notice: "Pagamento processado. Se aprovado, os contatos foram liberados."
  end

  # Webhook assíncrono → Mercado Pago chama a plataforma
  def webhook
    PagamentoPixService.new.webhook(params)
    head :ok
  end

  # Rota simples para healthcheck de pagamentos
  def ping
    head :ok
  end

  private

  # Decide se cliente é PF, PJ fidelizado ou avulso
  def identificar_cliente(frete)
    return frete.cliente if frete.cliente.present?
    return frete.cliente_cnpj if frete.respond_to?(:cliente_cnpj) && frete.cliente_cnpj.present?
    nil
  end

  # Busca o transportador (cotação aceita ou vinculado direto)
  def identificar_transportador(frete)
    frete.transportador || frete.cotacoes.aceitas.first&.transportador
  end

  # Calcula valor base considerando fidelidade e desconto
  def calcular_valor_final(frete, cliente)
    valor_base = frete.valor_total

    if cliente.respond_to?(:assinante?) && cliente.assinante?
      # Exemplo: PJ fidelizado tem 5% desconto
      valor_base - (valor_base * 0.05)
    else
      valor_base
    end
  end
end
