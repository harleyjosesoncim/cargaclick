module Webhooks
  class MercadoPagoController < ApplicationController
    skip_before_action :verify_authenticity_token

    def callback
      payment_id = params.dig("data", "id")
      frete = Frete.find_by(external_payment_id: payment_id)
      frete.update!(status_pagamento: :pago) if frete
      head :ok
    end
  end
end
