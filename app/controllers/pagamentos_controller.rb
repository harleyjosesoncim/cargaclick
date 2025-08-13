# frozen_string_literal: true
class PagamentosController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :webhook
  before_action :ensure_mp_token!

  TAXA = 9.90 # R$ (ajuste como quiser)

  def checkout
    frete = Frete.find(params[:frete_id])

    pref_data = {
      items: [{
        title: "Desbloqueio de contato - Frete ##{frete.id}",
        quantity: 1,
        currency_id: "BRL",
        unit_price: TAXA.to_f
      }],
      back_urls: {
        success: pagamentos_retorno_url(host: app_host, protocol: app_protocol),
        failure: pagamentos_retorno_url(host: app_host, protocol: app_protocol),
        pending: pagamentos_retorno_url(host: app_host, protocol: app_protocol)
      },
      auto_return: "approved",
      external_reference: "frete:#{frete.id}",
      # URL pública e absoluta para o webhook
      notification_url: pagamentos_webhook_url(host: app_host, protocol: app_protocol)
    }

    pref = mp_sdk.preference.create(pref_data)
    url  = pref.dig("response", "init_point") || pref.dig("response", "sandbox_init_point")
    render json: { url: url }
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Frete não encontrado" }, status: :not_found
  rescue => e
    Rails.logger.error("MP checkout error: #{e.class} - #{e.message}")
    render json: { error: "Falha ao iniciar pagamento" }, status: :unprocessable_entity
  end

  def retorno
    payment_id = params[:payment_id] || params[:collection_id]
    marcar_pago_se_aprovado(payment_id) if payment_id.present?
    redirect_to root_path, notice: "Pagamento processado. Se aprovado, os contatos foram liberados."
  end

  def webhook
    topic = params[:type] || params[:topic]
    id    = params[:id] || params.dig(:data, :id) || params.dig("data", "id")
    marcar_pago_se_aprovado(id) if topic == "payment" && id.present?
    head :ok
  end

  private

  # ---- Helpers de MP ----
  def mp_token
    Rails.configuration.x.mercadopago_access_token
  end

  def mp_sdk
    @mp_sdk ||= Mercadopago::SDK.new(mp_token)
  end

  def ensure_mp_token!
    return if mp_token.present?

    msg = "MP_ACCESS_TOKEN não configurado. Defina ENV['MP_ACCESS_TOKEN'] " \
          "ou credentials[:mercadopago][:access_token]."
    Rails.logger.error(msg)
    render plain: msg, status: :service_unavailable if Rails.env.production?
  end

  # ---- Helpers de URL absolutas (evita depender de default_url_options) ----
  def app_host
    ENV['APP_HOST'].presence || request.host
  end

  def app_protocol
    (ENV['APP_PROTOCOL'].presence || (request.ssl? ? 'https' : 'http')).to_s
  end

  def marcar_pago_se_aprovado(payment_id)
    payment = mp_sdk.payment.get(payment_id)
    status  = payment.dig("response", "status")
    ext_ref = payment.dig("response", "external_reference")
    return unless status == "approved" && ext_ref&.start_with?("frete:")

    frete_id = ext_ref.split(":").last
    Frete.where(id: frete_id).update_all(contatos_liberados: true)
  rescue => e
    Rails.logger.error("MP check error: #{e.class} - #{e.message}")
  end
end
# frozen_string_literal: true
# app/controllers/pagamentos_controller.rb
# Controller para gerenciar pagamentos via Mercado Pago
# Permite iniciar checkout, receber notificações e processar retornos
# Utiliza o SDK do Mercado Pago para interações com a API   
# Configura o token de acesso via variáveis de ambiente ou credentials
# Define taxa fixa para desbloqueio de contatos
# Implementa segurança básica com verificação de autenticidade e tratamento de erros
# Exemplo de uso:
# POST /pagamentos/checkout?frete_id=123
# Recebe o ID do frete e inicia o processo de checkout
# GET /pagamentos/retorno?payment_id=456
# Processa o retorno do pagamento e redireciona para a página inicial
# POST /pagamentos/webhook
# Recebe notificações do Mercado Pago e atualiza o status dos fretes
# Exemplo de configuração:
# ENV['MP_ACCESS_TOKEN'] = 'seu_token_aqui'
# Rails.application.credentials.mercadopago[:access_token] = 'seu_token_aqui'         