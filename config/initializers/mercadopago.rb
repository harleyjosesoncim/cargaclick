Rails.configuration.x.mercadopago_access_token =
  ENV["MP_ACCESS_TOKEN"] || Rails.application.credentials.dig(:mercadopago, :access_token)

unless defined?(Mercadopago)
  Rails.logger.warn("⚠️ gem 'mercadopago-sdk' não carregada. Adicione no Gemfile.")
end
