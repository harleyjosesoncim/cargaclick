module Webhooks
  class PixController < ApplicationController
    skip_before_action :verify_authenticity_token

    def mercado_pago
      payload = JSON.parse(request.raw_post)

      payment_id = payload.dig("data", "id")
      return head :ok unless payment_id

      result = MercadoPagoPixService.fetch(payment_id)
      return head :ok unless result[:approved]

      frete = Frete.find_by(external_payment_id: payment_id)
      return head :ok unless frete

      frete.update!(status_pagamento: :pago)
      head :ok
    end
  end
end
