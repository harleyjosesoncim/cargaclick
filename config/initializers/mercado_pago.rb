# frozen_string_literal: true

# Lê o token sem quebrar no precompile/sem master key
token =
  ENV["MP_ACCESS_TOKEN"].presence ||
  begin
    Rails.application.credentials.dig(:mercadopago, :access_token)
  rescue StandardError => e
    Rails.logger.info("[mercado_pago] credenciais indisponíveis no build (#{e.class}: #{e.message})")
    nil
  end

Rails.configuration.x.mercadopago_access_token = token

# Evita inicializar o SDK durante assets:precompile
skip_sdk = begin
  defined?(Rake) && Rake.application &&
    Rake.application.top_level_tasks.any? { |t| t.to_s.include?("assets:precompile") }
rescue StandardError
  false
end

# Só cria o SDK se a gem existir, houver token e não estivermos no precompile
if !skip_sdk && defined?(MercadoPago) && token.present?
  Rails.configuration.x.mercadopago_sdk = MercadoPago::SDK.new(token)
  Rails.logger.info("[mercado_pago] SDK inicializado")
else
  motivo =
    if skip_sdk
      "precompile de assets"
    elsif !defined?(MercadoPago)
      "gem ausente"
    elsif token.blank?
      "token ausente"
    else
      "condição não atendida"
    end

  Rails.configuration.x.mercadopago_sdk = nil
  Rails.logger.info("[mercado_pago] SDK desativado (#{motivo}) – env=#{Rails.env}")
end
