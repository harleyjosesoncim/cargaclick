# config/environments/production.rb
# frozen_string_literal: true

Rails.application.configure do
  # ============================================================
  # AMBIENTE: PRODUÇÃO
  # ============================================================
  config.cache_classes = true
  config.eager_load    = true
  config.consider_all_requests_local = false

  # Exige master key em runtime; pula no build de assets (SKIP_MASTER_KEY=1)
  config.require_master_key = ENV["SKIP_MASTER_KEY"] != "1"

  # ============================================================
  # HOSTS & SSL
  # ============================================================
  if (app_host = ENV["APP_HOST"]).present?
    config.hosts << app_host
  end
  config.hosts << /.*\.onrender\.com/
  # Smoke local em “prod”
  config.hosts << "localhost"
  config.hosts << "127.0.0.1"
  config.hosts << "::1"

  config.force_ssl = ActiveModel::Type::Boolean.new.cast(ENV.fetch("FORCE_SSL", "true"))
  config.ssl_options = { hsts: { expires: 1.year, subdomains: true, preload: true } }

  # Proteção extra
  config.action_controller.forgery_protection_origin_check = true

  # ============================================================
  # CACHE & ARQUIVOS ESTÁTICOS
  # ============================================================
  config.action_controller.perform_caching = true
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  if ENV["REDIS_URL"].present?
    config.cache_store = :redis_cache_store, {
      url: ENV["REDIS_URL"],
      error_handler: ->(method:, returning:, exception:) {
        Rails.logger.warn("Redis cache error: #{method} #{exception.class}: #{exception.message}")
      }
    }
  else
    config.cache_store = :memory_store, { size: 64.megabytes }
  end

  # ============================================================
  # ASSETS
  # ============================================================
  config.assets.js_compressor  = :terser   # gem 'terser'
  config.assets.css_compressor = nil       # Tailwind já minifica
  config.assets.compile        = false     # exige precompile no deploy
  config.assets.digest         = true
  config.assets.quiet          = true

  # ============================================================
  # ACTIVE STORAGE
  # ============================================================
  # Em produção real, prefira 'amazon'/'google'/'azure' (Render FS é efêmero)
  config.active_storage.service = ENV.fetch("ACTIVE_STORAGE_SERVICE", "local").to_sym

  # ============================================================
  # JOBS / BACKGROUND
  # ============================================================
  config.active_job.queue_adapter = ENV.fetch("QUEUE_ADAPTER", "async").to_sym
  config.active_job.queue_name_prefix = "cargaclick_production"

  # ============================================================
  # MAILER (SMTP via ENV)
  # ============================================================
  config.action_mailer.perform_caching       = false
  config.action_mailer.perform_deliveries    = true
  config.action_mailer.raise_delivery_errors = true
  config.action_mailer.delivery_method       = :smtp

  config.action_mailer.smtp_settings = {
    address:              ENV.fetch("SMTP_ADDRESS", "smtp.gmail.com"),
    port:                 ENV.fetch("SMTP_PORT", 587).to_i,
    user_name:            ENV["SMTP_USERNAME"],
    password:             ENV["SMTP_PASSWORD"],
    domain:               ENV.fetch("SMTP_DOMAIN", "cargaclick.com.br"),
    authentication:       ENV.fetch("SMTP_AUTH", "plain"),
    enable_starttls_auto: ENV.fetch("SMTP_ENABLE_STARTTLS_AUTO", "true") == "true",
    open_timeout:         ENV.fetch("SMTP_OPEN_TIMEOUT", 5).to_i,
    read_timeout:         ENV.fetch("SMTP_READ_TIMEOUT", 5).to_i
  }

  config.action_mailer.default_url_options = {
    host:     ENV.fetch("APP_HOST", "www.cargaclick.com.br"),
    protocol: ENV.fetch("APP_PROTOCOL", "https")
  }
  config.action_mailer.asset_host = "#{ENV.fetch("APP_PROTOCOL", "https")}://#{ENV.fetch("APP_HOST", "www.cargaclick.com.br")}"
  config.action_mailer.default_options = {
    from: ENV.fetch("MAILER_SENDER", "no-reply@cargaclick.com.br")
  }

  # ============================================================
  # LOGS (JSON com Lograge)
  # ============================================================
  config.log_level = (ENV["RAILS_LOG_LEVEL"] || :info).to_sym
  config.log_tags  = [:request_id]

  logger           = ActiveSupport::Logger.new($stdout)
  logger.formatter = ::Logger::Formatter.new
  config.logger    = ActiveSupport::TaggedLogging.new(logger)

  config.lograge.enabled                 = true
  config.lograge.keep_original_rails_log = false
  config.lograge.formatter               = Lograge::Formatters::Json.new
  config.lograge.ignore_actions          = ["Rails::HealthController#show"] # /up

  config.lograge.custom_payload do |controller|
    {
      host: controller.request.host,
      ip:   controller.request.remote_ip,
      ua:   controller.request.user_agent,
      admin_id:         controller.try(:current_admin_user)&.id,
      cliente_id:       controller.try(:current_cliente)&.id,
      transportador_id: controller.try(:current_transportador)&.id
    }
  end

  config.lograge.custom_options = lambda do |event|
    {
      time:       event.time.utc.iso8601,
      request_id: event.payload[:request_id],
      params:     event.payload[:params].except("controller", "action", "format")
    }
  end

  # Menos ruído de SQL
  config.active_record.logger = nil
  config.active_record.verbose_query_logs = false

  # ============================================================
  # BANCO DE DADOS
  # ============================================================
  config.active_record.dump_schema_after_migration = false

  # ============================================================
  # I18N & FALLBACKS
  # ============================================================
  config.i18n.fallbacks = true

  # ============================================================
  # ERROS & NOTIFICAÇÕES
  # ============================================================
  config.active_support.report_deprecations = false
  # Para páginas de erro customizadas: config.exceptions_app = routes
end
# EOF
