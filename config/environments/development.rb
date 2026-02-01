# frozen_string_literal: true

Rails.application.configure do
  # ============================================================
  # AMBIENTE: DESENVOLVIMENTO
  # ============================================================

  # Recarrega código a cada request
  config.cache_classes = false
  config.eager_load = false

  # Mostra erros completos no browser
  config.consider_all_requests_local = true

  # ============================================================
  # SSL — NUNCA forçar em development
  # ============================================================
  # 🔴 Forçar SSL em dev causa ERR_SSL_PROTOCOL_ERROR
  config.force_ssl = false

  # ============================================================
  # CACHE & ARQUIVOS ESTÁTICOS
  # ============================================================
  config.action_controller.perform_caching = false
  config.public_file_server.enabled = true

  # ============================================================
  # LOGS
  # ============================================================
  config.active_support.deprecation = :log
  config.active_support.report_deprecations = true
  config.active_support.disallowed_deprecation = nil
  config.active_support.disallowed_deprecation_warnings = []

  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "debug").to_sym

  config.logger = ActiveSupport::Logger.new($stdout)
  config.logger.formatter = ::Logger::Formatter.new

  # ============================================================
  # BANCO DE DADOS
  # ============================================================
  config.active_record.verbose_query_logs = true
  config.active_record.migration_error = :page_load

  # ============================================================
  # MAILER (DESENVOLVIMENTO)
  # ============================================================
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_caching = false
  config.action_mailer.delivery_method = :smtp

  config.action_mailer.smtp_settings = {
    address:              ENV.fetch("SMTP_ADDRESS", "smtp.gmail.com"),
    port:                 ENV.fetch("SMTP_PORT", 587),
    user_name:            ENV["SMTP_USERNAME"],
    password:             ENV["SMTP_PASSWORD"],
    domain:               ENV.fetch("SMTP_DOMAIN", "localhost"),
    authentication:       ENV.fetch("SMTP_AUTH", "plain"),
    enable_starttls_auto: true
  }

  # ⚠️ NUNCA HTTPS EM DEV
  config.action_mailer.default_url_options = {
    host: ENV.fetch("APP_HOST", "127.0.0.1"),
    port: ENV.fetch("APP_PORT", 3000),
    protocol: "http"
  }

  config.action_mailer.default_options = {
    from: ENV.fetch("MAILER_SENDER", "no-reply@cargaclick.app")
  }

  # ============================================================
  # ASSETS (TAILWIND / JS)
  # ============================================================
  config.assets.debug = true
  config.assets.quiet = true
end
