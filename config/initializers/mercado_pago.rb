# Lê token sem quebrar no precompile/sem master key
token =
  ENV["MP_ACCESS_TOKEN"].presence ||
  begin
    Rails.application.credentials.dig(:mercadopago, :access_token)
  rescue StandardError => e
    Rails.logger.info("[mercado_pago] credenciais indisponíveis no build: #{e.class}: #{e.message}")
    nil
  end

Rails.configuration.x.mercadopago_access_token = token

# Só cria o SDK se a gem existir e houver token
if defined?(MercadoPago) && token.present?
  MP_SDK = MercadoPago::SDK.new(token)
  Rails.logger.info("[mercado_pago] SDK inicializado")
else
  Rails.logger.info("[mercado_pago] SDK desativado (gem ou token ausentes) – env=#{Rails.env}")
end
