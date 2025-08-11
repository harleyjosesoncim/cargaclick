# frozen_string_literal: true

Devise.setup do |config|
  # --- Secret key (sem usar Rails.application.secrets) ------------------------
  creds = Rails.application.credentials

  config.secret_key =
    ENV["DEVISE_SECRET_KEY"] ||
    creds.dig(:devise, :secret_key) ||
    ENV["SECRET_KEY_BASE"] ||
    creds.secret_key_base

  # --- Mailer -----------------------------------------------------------------
  config.mailer_sender = ENV.fetch("MAILER_SENDER", "no-reply@cargaclick.app")
  # config.mailer = "Devise::Mailer"
  # config.parent_mailer = "ActionMailer::Base"

  # --- ORM --------------------------------------------------------------------
  require "devise/orm/active_record"

  # --- Auth keys --------------------------------------------------------------
  # config.authentication_keys = [:email]
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]

  # --- Sessão / CSRF ----------------------------------------------------------
  config.skip_session_storage = [:http_auth]
  # config.clean_up_csrf_token_on_authentication = true
  # config.reload_routes = true

  # --- Password hashing -------------------------------------------------------
  config.stretches = Rails.env.test? ? 1 : 12
  # config.pepper = ENV["DEVISE_PEPPER"]

  # --- Confirmable ------------------------------------------------------------
  config.reconfirmable = true

  # --- Rememberable -----------------------------------------------------------
  # config.remember_for = 2.weeks
  config.expire_all_remember_me_on_sign_out = true

  # --- Validatable ------------------------------------------------------------
  config.password_length = 6..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  # --- Timeoutable / Lockable -------------------------------------------------
  # config.timeout_in = 30.minutes
  # config.lock_strategy = :failed_attempts
  # config.unlock_strategy = :both

  # --- Recoverable ------------------------------------------------------------
  config.reset_password_within = 6.hours

  # --- Sign out ---------------------------------------------------------------
  config.sign_out_via = :delete

  # --- Hotwire / Turbo --------------------------------------------------------
  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other
end
