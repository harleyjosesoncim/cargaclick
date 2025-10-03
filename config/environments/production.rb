# config/environments/production.rb
# frozen_string_literal: true

Rails.application.configure do
  # ============================================================
  # AMBIENTE: PRODUÇÃO
  # ============================================================
  config.cache_classes = true
  config.eager_load    = true
  config.consider_all_requests_local = false

  # Em produção use credenciais/keys obrigatórias
  config.require_master_key = true

  # ============================================================
  # HOSTS & SSL
  # ============================================================
  # Permite seu domínio e o domínio de preview do Render
  if (app_host = ENV["APP_HOST"]).present?
    config.hosts << app_host
  end
  config.hosts << /.*\.onrender\.com/

  # Força HTTPS (pode desativar com FORCE_SSL=false)
  config.force_ssl = ActiveModel::Type::Boolean.new.cast(ENV.fetch("FORCE_SSL", "true"))
  config.ssl_options = {
    hsts: { expires: 1.year, subdomains: true, preload: true }
  }

  # Proteção extra contra CSRF via Origin/Host
  config.action_controller.forgery_protection_origin_check = true

  # ============================================================
  # CACHE & ARQUIVOS ESTÁTICOS
  # ============================================================
  config.action_controller.perform_caching = true

  # No Render, defina RAILS_SERVE_STATIC_FILES=1
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  # Cache (usa Redis se REDIS_URL definido, senão memória)
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
  config.assets.js_compressor  = :terser   # precisa do gem 'terser'
  config.assets.css_compressor = nil       # Tailwind já minifica
  config.assets.compile        = false     # exige precompile no deploy
  config.assets.digest         = true
  config.assets.quiet          = true

  # ============================================================
  # ACTIVE STORAGE
  # ============================================================
  # Escolha via env: 'amazon', 'google', 'azure', 'local' (config/storage.yml)
  config.active_storage.service = ENV.fetch("ACTIVE_STORAGE_SERVICE", "local").to_sym

  # ============================================================
  # JOBS / BACKGROUND
  # ============================================================
  # Use Sidekiq se tiver (QUEUE_ADAPTER=sidekiq)
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
  # LOGS
  # ============================================================
  config.log_level = (ENV["RAILS_LOG_LEVEL"] || :info).to_sym
  config.log_tags  = [:request_id]

  logger           = ActiveSupport::Logger.new($stdout)
  logger.formatter = ::Logger::Formatter.new
  config.logger    = ActiveSupport::TaggedLogging.new(logger)

  # Lograge (opcional). Ativa se o gem estiver presente.
  if defined?(Lograge)
    config.lograge.enabled = true
    config.lograge.formatter = Lograge::Formatters::Json.new
    config.lograge.keep_original_rails_log = false
    config.lograge.custom_payload do |controller|
      {
        host:   controller.request.host,
        user:   controller.try(:current_admin_user)&.id ||
                controller.try(:current_transportador)&.id ||
                controller.try(:current_cliente)&.id,
        params: controller.request.filtered_parameters.except("controller", "action")
      }
    end
  end

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

  # Páginas de erro estáticas (public/404.html etc) — padrão Rails
  # Se quiser usar rotas personalizadas: config.exceptions_app = routes
end
