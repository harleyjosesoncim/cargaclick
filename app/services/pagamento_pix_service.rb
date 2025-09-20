# app/services/pagamento_pix_service.rb
# frozen_string_literal: true

class PagamentoPixService
  # Comissão da CargaClick → menor que Uber/iFood (8%)
  TAXA_CARGACLICK = BigDecimal("0.08")

  def checkout_pf(frete, cliente, transportador, pagamento)
    valor_total = frete.valor_total
    comissao = (valor_total * TAXA_CARGACLICK).round(2)
    valor_liquido = valor_total - comissao

    pagamento.update!(
      valor_total: valor_total,
      valor_liquido: valor_liquido,
      comissao_cargaclick: comissao,
      status: "pendente"
    )

    criar_preferencia_pagamento(
      "Frete ##{frete.id} - Cliente PF",
      valor_total,
      frete.id
    )
  end

  def checkout_assinante(frete, cliente, transportador, pagamento)
    valor_total = frete.valor_total
    # PJ fidelizado → desconto e sem comissão sobre entregador
    desconto = (valor_total * 0.05).round(2)
    valor_final = valor_total - desconto

    pagamento.update!(
      valor_total: valor_total,
      valor_liquido: valor_final,
      comissao_cargaclick: 0,
      status: "pendente"
    )

    criar_preferencia_pagamento(
      "Frete ##{frete.id} - Cliente PJ Assinante",
      valor_final,
      frete.id
    )
  end

  def checkout_avulso(frete, cliente, transportador, pagamento)
    valor_total = frete.valor_total

    pagamento.update!(
      valor_total: valor_total,
      valor_liquido: valor_total,
      comissao_cargaclick: 0,
      status: "pendente"
    )

    criar_preferencia_pagamento(
      "Frete ##{frete.id} - Cliente Avulso",
      valor_total,
      frete.id
    )
  end

  # === Retorno e Webhook =============================
  def retorno(params)
    payment_id = params[:payment_id].presence || params[:collection_id].presence
    marcar_pago_se_aprovado(payment_id) if payment_id.present?
  end

  def webhook(params)
    topic = params[:type].presence || params[:topic].presence
    id = params[:id].presence || params.dig(:data, :id)

    case topic
    when "payment"        then marcar_pago_se_aprovado(id)
    when "merchant_order" then processar_merchant_order(id)
    end
  end

  private

  def criar_preferencia_pagamento(titulo, valor, frete_id)
    pref_data = {
      items: [{
        title: titulo,
        quantity: 1,
        currency_id: "BRL",
        unit_price: valor.to_f
      }],
      external_reference: "frete:#{frete_id}",
      auto_return: "approved",
      notification_url: Rails.application.routes.url_helpers.pagamentos_webhook_url(
        host: app_host, protocol: app_protocol
      )
    }

    resp  = mp_sdk.preference.create(pref_data)
    body  = indifferent(resp, :response)

    if (init = indifferent(body, :init_point))
      success(url: init, preference_id: indifferent(body, :id))
    else
      failure("Falha ao iniciar pagamento")
    end
  end

  def marcar_pago_se_aprovado(payment_id)
    return if Rails.cache.read("mp:paid:#{payment_id}").present?

    payment_resp = mp_sdk.payment.get(payment_id)
    body   = indifferent(payment_resp, :response)
    status = indifferent(body, :status)
    extref = indifferent(body, :external_reference)

    return unless body && status == "approved" && extref.to_s.start_with?("frete:")

    frete_id = extref.split(":").last
    frete = Frete.find_by(id: frete_id)
    pagamento = Pagamento.find_by(frete_id: frete_id)

    if pagamento
      pagamento.update!(status: "confirmado", txid: payment_id)
    else
      Pagamento.create!(
        frete_id: frete_id,
        transportador_id: frete&.transportador_id,
        valor_total: body[:transaction_amount],
        valor_liquido: body[:transaction_amount],
        comissao_cargaclick: 0,
        status: "confirmado",
        txid: payment_id
      )
    end

    frete.update(contatos_liberados: true) if frete.present?
    Rails.cache.write("mp:paid:#{payment_id}", true, expires_in: 3.days)

    Rails.logger.info("[MP] Pagamento confirmado, frete #{frete_id} liberado")
  rescue StandardError => e
    Rails.logger.error("[MP] erro ao confirmar pagamento: #{e.message}")
  end

  def processar_merchant_order(merchant_order_id)
    mo_resp = mp_sdk.merchant_order.get(merchant_order_id)
    mo = indifferent(mo_resp, :response) || {}
    pays = indifferent(mo, :payments) || []
    aprovado = pays.find { |p| indifferent(p, :status) == "approved" }
    marcar_pago_se_aprovado(indifferent(aprovado, :id)) if aprovado
  end

  # === Helpers ======================================
  def mp_sdk
    @mp_sdk ||= Mercadopago::SDK.new(ENV.fetch("MP_ACCESS_TOKEN"))
  end

  def app_host
    ENV["APP_HOST"].presence || Rails.application.config.hosts.first
  end

  def app_protocol
    ENV["APP_PROTOCOL"].presence || "https"
  end

  def indifferent(obj, key)
    return nil unless obj.is_a?(Hash)
    obj[key] || obj[key.to_s] || obj[key.to_sym]
  end

  def success(data); OpenStruct.new(success?: true, data: data); end
  def failure(error); OpenStruct.new(success?: false, error: error); end
end
