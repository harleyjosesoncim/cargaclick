module Webhooks
  module Pix
    class PixController < ApplicationController
      skip_before_action :verify_authenticity_token

      def create
        begin
          payload = params.to_unsafe_h
          processar_eventos(payload["pix"]) if payload["pix"].is_a?(Array)
          head :ok
        rescue => e
          Rails.logger.error("[WEBHOOK PIX EFI] Erro ao processar webhook: #{e.message}")
          Rails.logger.error(e.backtrace.join("\n"))
          head :internal_server_error
        end
      end

      private

      def processar_eventos(pix_array)
        pix_array.each do |pix|
          txid = pix["txid"]
          next if txid.blank?

          frete = Frete.find_by(pix_txid: txid)

          unless frete
            Rails.logger.warn("[WEBHOOK PIX EFI] Frete não encontrado para txid=#{txid}")
            next
          end

          if frete.status_pagamento == "pago"
            Rails.logger.info("[WEBHOOK PIX EFI] Frete ##{frete.id} já está marcado como pago.")
            next
          end

          frete.update!(status_pagamento: "pago")
          Rails.logger.info("[WEBHOOK PIX EFI] Frete ##{frete.id} marcado como pago com sucesso.")
        end
      end
    end
  end
end

