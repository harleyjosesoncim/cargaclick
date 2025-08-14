# Exponha o token do MP sem quebrar no boot/precompile
Rails.configuration.x.mercadopago_access_token =
  ENV['MP_ACCESS_TOKEN'] ||
  Rails.application.credentials.dig(:mercadopago, :access_token)

