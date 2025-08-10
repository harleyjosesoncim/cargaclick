# frozen_string_literal: true

Devise.setup do |config|
  # ---- Secret key (sem usar Rails.application.secrets) -----------------------
  # Ordem de busca:
  # 1) ENV["DEVISE_SECRET_KEY"]
  # 2) credentials.devise_secret_key
  # 3) SECRET_KEY_BASE (env ou credentials)
  config.secret_key =
    ENV["DEVISE_SECRET_KEY"] ||
    (Rails.application.credentials.respond_to?(:devise_secret_key) ? Rails.application.credentials.devise_secret_key : nil) ||
    ENV["SECRET_KEY_BASE"] ||
    (Rails.application.credentials.respond_to?(:secret_key_base) ? Rails.application.credentials.secret_key_base : nil)

  # ---- Mailer ----------------------------------------------------------------
  config.mailer_sender = ENV.fetch("MAILER_SENDER", "no-reply@cargaclick.app")
  # config.mailer = "Devise::Mailer"
  # config.parent_mailer = "ActionMailer::Base"

  # ---- ORM -------------------------------------------------------------------
  require "devise/orm/active_record"

  # ---- Auth keys --------------------------------------------------------------
  # config.authentication_keys = [:email]
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]

  # ---- Sessão / CSRF ----------------------------------------------------------
  config.skip_session_storage = [:http_auth]
  # config.clean_up_csrf_token_on_authentication = true
  # config.reload_routes = true

  # ---- Password hashing -------------------------------------------------------
  config.stretches = Rails.env.test? ? 1 : 12
  # config.pepper = ENV["DEVISE_PEPPER"]

  # ---- Confirmable ------------------------------------------------------------
  config.reconfirmable = true
  # config.allow_unconfirmed_access_for = 0.days
  # config.confirm_within = nil
  # config.confirmation_keys = [:email]

  # ---- Rememberable -----------------------------------------------------------
  # config.remember_for = 2.weeks
  config.expire_all_remember_me_on_sign_out = true
  # config.extend_remember_period = false
  # config.rememberable_options = {}

  # ---- Validatable ------------------------------------------------------------
  config.password_length = 6..128
  config.email_regexp = /\A[^@\s]+@[^@\s]+\z/

  # ---- Timeoutable / Lockable -------------------------------------------------
  # config.timeout_in = 30.minutes
  # config.lock_strategy = :failed_attempts
  # config.unlock_strategy = :both
  # config.maximum_attempts = 20
  # config.unlock_in = 1.hour
  # config.last_attempt_warning = true

  # ---- Recoverable ------------------------------------------------------------
  # config.reset_password_keys = [:email]
  config.reset_password_within = 6.hours
  # config.sign_in_after_reset_password = true

  # ---- Scopes / Navegação -----------------------------------------------------
  # config.scoped_views = false
  # config.default_scope = :user
  # config.sign_out_all_scopes = true
  # config.navigational_formats = ["*/*", :html, :turbo_stream]

  # ---- Sign out ---------------------------------------------------------------
  config.sign_out_via = :delete

  # ---- OmniAuth ---------------------------------------------------------------
  # config.omniauth :github, ENV["GITHUB_CLIENT_ID"], ENV["GITHUB_CLIENT_SECRET"], scope: "user,public_repo"

  # ---- Warden -----------------------------------------------------------------
  # config.warden do |manager|
  #   manager.intercept_401 = false
  # end

  # ---- Hotwire / Turbo --------------------------------------------------------
  config.responder.error_status = :unprocessable_entity
  config.responder.redirect_status = :see_other

  # ---- Após trocar senha ------------------------------------------------------
  # config.sign_in_after_change_password = true
end
