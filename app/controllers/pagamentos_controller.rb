# frozen_string_literal: true
class PagamentosController < ApplicationController
  skip_before_action :verify_authenticity_token, only: :webhook

  TAXA = 9.90 # R$ (ajuste como quiser)

  def checkout
    frete = Frete.find(params[:frete_id])

    sdk = Mercadopago::SDK.new(ENV.fetch("MP_ACCESS_TOKEN"))
    pref_data = {
      items: [{
        title: "Desbloqueio de contato - Frete ##{frete.id}",
        quantity: 1,
        currency_id: "BRL",
        unit_price: TAXA.to_f
      }],
      back_urls: {
        success: pagamentos_retorno_url,
        failure: pagamentos_retorno_url,
        pending: pagamentos_retorno_url
      },
      auto_return: "approved",
      external_reference: "frete:#{frete.id}",
      notification_url: pagamentos_webhook_url # tem que ser https público
    }

    pref = sdk.preference.create(pref_data)
    url  = pref.dig("response", "init_point") || pref.dig("response", "sandbox_init_point")
    render json: { url: url }
  rescue => e
    Rails.logger.error("MP checkout error: #{e.class} - #{e.message}")
    render json: { error: "Falha ao iniciar pagamento" }, status: :unprocessable_entity
  end

  def retorno
    payment_id = params[:payment_id] || params[:collection_id]
    if payment_id.present?
      marcar_pago_se_aprovado(payment_id)
    end
    redirect_to root_path, notice: "Pagamento processado. Se aprovado, os contatos foram liberados."
  end

  def webhook
    topic = params[:type] || params[:topic]
    id    = params[:id] || params.dig(:data, :id) || params.dig("data", "id")
    marcar_pago_se_aprovado(id) if topic == "payment" && id.present?
    head :ok
  end

  private

  def marcar_pago_se_aprovado(payment_id)
    sdk     = Mercadopago::SDK.new(ENV.fetch("MP_ACCESS_TOKEN"))
    payment = sdk.payment.get(payment_id)
    status  = payment.dig("response", "status")
    ext_ref = payment.dig("response", "external_reference")
    return unless status == "approved" && ext_ref&.start_with?("frete:")

    frete_id = ext_ref.split(":").last
    Frete.where(id: frete_id).update_all(contatos_liberados: true)
  rescue => e
    Rails.logger.error("MP check error: #{e.class} - #{e.message}")
  end
end
