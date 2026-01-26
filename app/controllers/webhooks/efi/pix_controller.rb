module Webhooks
  module Efi
    class PixController < ApplicationController
      skip_before_action :verify_authenticity_token

      def callback
        frete = Frete.find_by(external_reference: params[:txid])
        frete.update!(status_pagamento: :pago) if frete
        head :ok
      end
    end
  end
end
