# config/environments/production.rb
# frozen_string_literal: true

Rails.application.configure do
  # ============================================================
  # AMBIENTE: PRODUÇÃO
  # ============================================================
  config.cache_classes = true
  config.eager_load    = true
  config.consider_all_requests_local = false

  # ============================================================
  # CACHE & ARQUIVOS ESTÁTICOS
  # ============================================================
  config.action_controller.perform_caching = true
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  # Compressão e compilação de assets
  config.assets.js_compressor  = :terser   # Compatível com ES6+
  config.assets.css_compressor = nil       # Tailwind já minifica
  config.assets.compile        = false     # exige precompile no deploy
  config.assets.digest         = true      # cache busting fingerprint

  # ============================================================
  # LOGS
  # ============================================================
  config.log_level = (ENV["RAILS_LOG_LEVEL"] || :info).to_sym
  config.log_tags  = [:request_id]

  logger           = ActiveSupport::Logger.new($stdout)
  logger.formatter = ::Logger::Formatter.new
  config.logger    = ActiveSupport::TaggedLogging.new(logger)

  # ============================================================
  # BANCO DE DADOS
  # ============================================================
  config.active_record.dump_schema_after_migration = false

  # ============================================================
  # MAILER (SMTP via ENV)
  # ============================================================
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.perform_caching       = false
  config.action_mailer.delivery_method       = :smtp

  config.action_mailer.smtp_settings = {
    address:              ENV.fetch("SMTP_ADDRESS", "smtp.gmail.com"),
    port:                 ENV.fetch("SMTP_PORT", 587),
    user_name:            ENV["SMTP_USERNAME"],
    password:             ENV["SMTP_PASSWORD"],
    domain:               ENV.fetch("SMTP_DOMAIN", "cargaclick.com.br"),
    authentication:       ENV.fetch("SMTP_AUTH", "plain"),
    enable_starttls_auto: ENV.fetch("SMTP_ENABLE_STARTTLS_AUTO", "true") == "true"
  }

  config.action_mailer.default_url_options = {
    host:     ENV.fetch("APP_HOST", "www.cargaclick.com.br"),
    protocol: ENV.fetch("APP_PROTOCOL", "https")
  }

  config.action_mailer.default_options = {
    from: ENV.fetch("MAILER_SENDER", "no-reply@cargaclick.com.br")
  }

  # ============================================================
  # I18N & FALLBACKS
  # ============================================================
  config.i18n.fallbacks = true

  # ============================================================
  # ERROS & NOTIFICAÇÕES
  # ============================================================
  config.active_support.report_deprecations = false
end

# vim: set ft=ruby ts=2 sw=2 et:
# encoding: utf-8
# frozen_string_literal: true