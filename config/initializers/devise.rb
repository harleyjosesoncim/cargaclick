# frozen_string_literal: true

Devise.setup do |config|
  creds = Rails.application.credentials

  config.secret_key =
    ENV["DEVISE_SECRET_KEY"] ||
    creds.dig(:devise, :secret_key) ||
    ENV["SECRET_KEY_BASE"] ||
    creds.secret_key_base

  config.mailer_sender = ENV.fetch("MAILER_SENDER", "no-reply@cargaclick.app")
  require "devise/orm/active_record"

  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]
  config.skip_session_storage = [:http_auth]

  config.stretches = Rails.env.test? ? 1 : 12
  config.reconfirmable = true

  config.expire_all_remember_me_on_sign_out = true
  config.password_length = 6..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  config.reset_password_within = 6.hours
  config.sign_out_via = :delete

  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other
end
