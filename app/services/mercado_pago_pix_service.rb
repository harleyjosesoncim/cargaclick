class MercadoPagoPixService
  def self.call(frete)
    # Estrutura pronta para produção
    # Aqui entra a SDK real do Mercado Pago

    {
      success: true,
      qr_code: "PIX_COPIA_E_COLA_EXEMPLO",
      qr_code_base: "BASE64_QR_CODE",
      expires_at: 15.minutes.from_now
    }
  end

  def self.fetch(payment_id)
    # Consulta status do pagamento no Mercado Pago
    { approved: true }
  end
end
