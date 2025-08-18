# frozen_string_literal: true

require "bigdecimal"

class PagamentosController < ApplicationController
  # Webhooks externos não têm CSRF; e HEAD /pagamentos/webhook é só um ping
  skip_before_action :verify_authenticity_token, only: %i[webhook ping]
  # Verifica token/SDK antes de chamar API (não precisa no ping)
  before_action :ensure_mp_ready!, except: :ping

  TAXA = BigDecimal("9.90") # R$ por desbloqueio

  # POST /pagamentos/checkout?frete_id=123
  def checkout
    frete_id = params[:frete_id].presence
    return render json: { error: "Parâmetro frete_id é obrigatório" }, status: :bad_request if frete_id.blank?

    frete = Frete.find(frete_id)

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
        pending:  pagamentos_retorno_url(host: app_host, protocol: app_protocol)
      },
      auto_return: "approved",
      external_reference: "frete:#{frete.id}",
      notification_url: pagamentos_webhook_url(host: app_host, protocol: app_protocol)
    }

    resp  = mp_sdk.preference.create(pref_data)
    body  = indifferent(resp, :response)
    init  = indifferent(body, :init_point) || indifferent(body, :sandbox_init_point)

    if init.present?
      render json: { url: init, preference_id: indifferent(body, :id) }
    else
      Rails.logger.error("[MP] Resposta inesperada ao criar preference: #{resp.inspect}")
      render json: { error: "Falha ao iniciar pagamento" }, status: :unprocessable_entity
    end
  rescue ActiveRecord::RecordNotFound
    render json: { error: "Frete não encontrado" }, status: :not_found
  rescue StandardError => e
    Rails.logger.error("[MP] checkout error: #{e.class} - #{e.message}")
    render json: { error: "Falha ao iniciar pagamento" }, status: :unprocessable_entity
  end

  # GET /pagamentos/retorno?payment_id=... (ou collection_id)
  def retorno
    payment_id = params[:payment_id].presence || params[:collection_id].presence
    marcar_pago_se_aprovado(payment_id) if payment_id.present?
    redirect_to root_path, notice: "Pagamento processado. Se aprovado, os contatos foram liberados."
  end

  # POST /pagamentos/webhook
  # MP envia variações:
  #  - topic/type = "payment" com id=payment_id
  #  - topic/type = "merchant_order" com id=merchant_order_id
  def webhook
    topic = params[:type].presence || params[:topic].presence
    id =
      params[:id].presence ||
      params.dig(:data, :id).presence ||
      params.dig("data", "id").presence

    case topic
    when "payment"
      marcar_pago_se_aprovado(id) if id.present?
    when "merchant_order"
      processar_merchant_order(id) if id.present?
    else
      Rails.logger.info("[MP] Webhook ignorado: topic=#{topic.inspect} id=#{id.inspect}")
    end

    head :ok
  rescue StandardError => e
    Rails.logger.error("[MP] webhook error: #{e.class} - #{e.message}")
    head :ok
  end

  # HEAD /pagamentos/webhook (ping de CDN/monitor)
  def ping
    head :ok
  end

  private

  # -------------------- Mercado Pago helpers --------------------

  def mp_token
    # definido no initializer: ENV['MP_ACCESS_TOKEN'] || credentials[:mercadopago][:access_token]
    Rails.configuration.x.mercadopago_access_token
  end

  def mp_sdk
    return MP_SDK if defined?(MP_SDK) && MP_SDK # permite injetar SDK global
    # ATENÇÃO: o namespace correto da gem é "Mercadopago"
    @mp_sdk ||= Mercadopago::SDK.new(mp_token)
  end

  def ensure_mp_ready!
    unless mp_token.present?
      msg = "MP_ACCESS_TOKEN não configurado. Defina ENV['MP_ACCESS_TOKEN'] "\
            "ou credentials[:mercadopago][:access_token]."
      Rails.logger.error(msg)
      return render json: { error: msg }, status: :service_unavailable
    end

    unless defined?(Mercadopago)
      msg = "SDK do Mercado Pago não carregada. Adicione ao Gemfile: gem 'mercadopago-sdk'"
      Rails.logger.error(msg)
      return render json: { error: msg }, status: :service_unavailable
    end
  end

  # -------------------- URLs absolutas --------------------

  def app_host
    ENV["APP_HOST"].presence || request.host
  end

  def app_protocol
    (ENV["APP_PROTOCOL"].presence || (request.ssl? ? "https" : "http")).to_s
  end

  # -------------------- Pagamento --------------------

  # Idempotência simples usando cache por payment_id (evita liberar 2x)
  def ja_processado?(payment_id)
    Rails.cache.read("mp:paid:#{payment_id}").present?
  end

  def marcar_como_processado(payment_id)
    Rails.cache.write("mp:paid:#{payment_id}", true, expires_in: 3.days)
  end

  def marcar_pago_se_aprovado(payment_id)
    return if payment_id.blank?
    return if ja_processado?(payment_id)

    payment_resp = mp_sdk.payment.get(payment_id)
    body   = indifferent(payment_resp, :response)
    status = indifferent(body, :status)
    extref = indifferent(body, :external_reference)

    unless body
      Rails.logger.error("[MP] Resposta de payment.get inválida: #{payment_resp.inspect}")
      return
    end

    unless status == "approved"
      Rails.logger.info("[MP] Pagamento #{payment_id} com status=#{status.inspect} (não é approved)")
      return
    end

    unless extref.is_a?(String) && extref.start_with?("frete:")
      Rails.logger.error("[MP] external_reference inválido: #{extref.inspect}")
      return
    end

    frete_id = extref.split(":", 2).last
    updated  = Frete.where(id: frete_id, contatos_liberados: [false, nil]).update_all(contatos_liberados: true)

    marcar_como_processado(payment_id) if updated.positive?
    Rails.logger.info("[MP] Frete ##{frete_id} liberado (updated=#{updated}, payment_id=#{payment_id})")
  rescue StandardError => e
    Rails.logger.error("[MP] check error: #{e.class} - #{e.message}")
  end

  # Suporte ao fluxo quando o tópico é merchant_order
  def processar_merchant_order(merchant_order_id)
    mo_resp = mp_sdk.merchant_order.get(merchant_order_id)
    mo      = indifferent(mo_resp, :response) || {}
    extref  = indifferent(mo, :external_reference)
    pays    = indifferent(mo, :payments) || []

    # se houver algum pagamento approved, processa
    aprovado = pays.find { |p| indifferent(p, :status) == "approved" }
    if aprovado
      marcar_pago_se_aprovado(indifferent(aprovado, :id))
      return
    end

    # fallback: se não veio payments mas há external_reference de frete, tente conferir via search
    if extref.is_a?(String) && extref.start_with?("frete:")
      Rails.logger.info("[MP] merchant_order sem payment approved ainda (extref=#{extref})")
    else
      Rails.logger.info("[MP] merchant_order ignorado: sem payments/aprovação (id=#{merchant_order_id})")
    end
  rescue StandardError => e
    Rails.logger.error("[MP] merchant_order error: #{e.class} - #{e.message}")
  end

  # Acesso indiferente a string/símbolo
  def indifferent(obj, key)
    return nil unless obj.is_a?(Hash)
    obj[key] || obj[key.to_s] || obj[key.to_sym]
  end
end
