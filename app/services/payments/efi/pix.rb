module Payments
  module Efi
    class Pix
      def self.call(frete)
        # Placeholder para integração real EFI
        {
          provider: "efi",
          txid: "TXID123",
          qr_code: "PIX_EFI_COPIA_E_COLA",
          expires_at: 15.minutes.from_now
        }
      end
    end
  end
end
