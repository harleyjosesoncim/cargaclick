# frozen_string_literal: true

class MercadoPagoService
  def initialize
    @sdk = Rails.configuration.x.mercadopago_sdk
  end

  # Cria uma preferência de pagamento no MP
  def criar_preferencia(pagamento)
    preference_data = {
      items: [
        {
          title: "Frete ##{pagamento.frete_id}",
          quantity: 1,
          currency_id: "BRL",
          unit_price: pagamento.valor_total.to_f
        }
      ],
      payer: { email: pagamento.cliente.email },
      back_urls: {
        success: Rails.application.routes.url_helpers.callback_pagamentos_url(status: "success"),
        failure: Rails.application.routes.url_helpers.callback_pagamentos_url(status: "failure"),
        pending: Rails.application.routes.url_helpers.callback_pagamentos_url(status: "pending")
      },
      auto_return: "approved"
    }

    @sdk.preference.create(preference_data)
  end

  def consultar_pagamento(mp_payment_id)
    @sdk.payment.get(mp_payment_id)
  end
end
