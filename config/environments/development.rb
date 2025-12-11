# config/environments/development.rb
# frozen_string_literal: true

Rails.application.configure do
  # ============================================================
  # AMBIENTE: DESENVOLVIMENTO
  # ============================================================

  # Recarrega o código a cada request (mais lento, mas ideal em dev)
  config.cache_classes = false
  config.eager_load = false

  # Mostra erros detalhados no navegador
  config.consider_all_requests_local = true

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

  config.log_level = (ENV.fetch("RAILS_LOG_LEVEL", "debug")).to_sym
  config.logger    = ActiveSupport::Logger.new($stdout)

  # ============================================================
  # BANCO DE DADOS
  # ============================================================
  # Mostra SQL detalhado no log para debug
  config.active_record.verbose_query_logs = true
  # Mostra erro se houver migrations pendentes
  config.active_record.migration_error = :page_load

  # ============================================================
  # MAILER (SMTP via .env)
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
    enable_starttls_auto: ENV.fetch("SMTP_ENABLE_STARTTLS_AUTO", "true") == "true"
  }

  config.action_mailer.default_url_options = {
    host:     ENV.fetch("APP_HOST", "localhost"),
    port:     ENV.fetch("APP_PORT", 3000),
    protocol: ENV.fetch("APP_PROTOCOL", "http")
  }

  config.action_mailer.default_options = {
    from: ENV.fetch("MAILER_SENDER", "no-reply@cargaclick.app")
  }

  # ============================================================
  # ASSETS (Tailwind / JS no DEV)
  # ============================================================
  config.assets.debug = true   # mostra cada arquivo separado
  config.assets.quiet = true   # silencia logs de assets no console
end
