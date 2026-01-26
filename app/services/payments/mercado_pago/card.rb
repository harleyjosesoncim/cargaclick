module Payments
  module MercadoPago
    class Card
      def self.call(frete, params)
        {
          provider: "mercadopago",
          payment_id: "MP123",
          status: "approved"
        }
      end
    end
  end
end
