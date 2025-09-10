# frozen_string_literal: true

# Mercado Pago – só inicializa em produção
if Rails.env.production?
  token =
    ENV["MP_ACCESS_TOKEN"].presence ||
    begin
      Rails.application.credentials.dig(:mercadopago, :access_token)
    rescue StandardError
      nil
    end

  if token.present?
    Rails.configuration.x.mercadopago_access_token = token
    Rails.configuration.x.mercadopago_sdk = MercadoPago::SDK.new(token)

    Rails.logger.info("[mercado_pago] SDK inicializado em produção")

    # 🔗 Integração base com modelos
    #
    # Pagamento pertence a um frete e a um transportador.
    # Cliente dispara o pagamento, transportador recebe.
    #
    # Estrutura:
    # - frete_id → ligação com a corrida
    # - cliente_id → quem paga
    # - transportador_id → quem recebe
    # - chave_pix (ou email MP) → destino do pagamento
    #
    # Isso garante que os botões de checkout apontem para o transportador correto.
  else
    Rails.logger.warn("[mercado_pago] token ausente em produção")
  end
end
