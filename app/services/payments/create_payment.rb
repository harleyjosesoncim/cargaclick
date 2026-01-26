module Payments
  class CreatePayment
    def self.call(frete:, metodo:, params: {})
      case metodo.to_sym
      when :pix
        Payments::Efi::Pix.call(frete)
      when :cartao
        Payments::MercadoPago::Card.call(frete, params)
      else
        raise ArgumentError, "Método de pagamento inválido"
      end
    end
  end
end
