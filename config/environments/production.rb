# config/environments/production.rb
# frozen_string_literal: true

Rails.application.configure do
  # ============================================================
  # AMBIENTE: PRODUÇÃO
  # ============================================================
  config.cache_classes = true
  config.eager_load    = true
  config.consider_all_requests_local = false
  config.action_view.cache_template_loading = true

  # Exigir master key em runtime; permite pular apenas no build de assets
  # use no build: SKIP_MASTER_KEY=1 bundle exec rake assets:precompile
  config.require_master_key = ENV["SKIP_MASTER_KEY"] != "1"

  # ============================================================
  # HOSTS & SSL
  # ============================================================
  # Domínio(s) permitidos
  app_host = ENV["APP_HOST"]
  config.hosts << app_host if app_host.present?
  config.hosts << "www.cargaclick.com.br"
  config.hosts << /.*\.onrender\.com/
  # Smoke/local em “prod” (opcional)
  config.hosts << "localhost"
  config.hosts << "127.0.0.1"
  config.hosts << "::1"

  # Força HTTPS (por padrão)
  config.force_ssl = ActiveModel::Type::Boolean.new.cast(ENV.fetch("FORCE_SSL", "true"))
  config.ssl_options = { hsts: { expires: 1.year, subdomains: true, preload: true } }

  # Proteção extra CSRF
  config.action_controller.forgery_protection_origin_check = true

  # ============================================================
  # CACHE & ARQUIVOS ESTÁTICOS
  # ============================================================
  config.action_controller.perform_caching = true
  config.action_controller.enable_fragment_cache_logging = false

  # Servir estáticos (Render/Heroku setam RAILS_SERVE_STATIC_FILES)
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
  # Cache agressivo para estáticos fingerprintados
  config.public_file_server.headers = {
    "Cache-Control" => "public, max-age=31536000, immutable"
  }

  # Cache store com Redis e fallback seguro
  if ENV["REDIS_URL"].present?
    config.cache_store = :redis_cache_store, {
      url: ENV["REDIS_URL"],
      reconnect_attempts: 3,
      error_handler: ->(method:, returning:, exception:) {
        Rails.logger.warn "Redis cache error: #{method} returning=#{returning} #{exception.class}: #{exception.message}"
      }
      # Se seu provedor usar TLS (rediss://), você pode habilitar ssl_params:
      # ssl_params: { verify_mode: OpenSSL::SSL::VERIFY_NONE }
    }
  else
    Rails.logger.warn "REDIS_URL ausente; usando :memory_store (fallback não recomendado em multi-instância)"
    config.cache_store = :memory_store, { size: 64.megabytes }
  end

  # ============================================================
  # ASSETS
  # ============================================================
  # Se usar Sprockets + esbuild/tailwindcli, deixe o CSS compressor nil (Tailwind já minifica)
  config.assets.js_compressor  = :terser # gem 'terser'
  config.assets.css_compressor = nil
  config.assets.compile        = false   # exige precompile no deploy
  config.assets.digest         = true
  config.assets.quiet          = true
  # O path de builds (esbuild/tailwind) deve estar em initializers/assets.rb:
  # Rails.application.config.assets.paths << Rails.root.join("app/assets/builds")

  # ============================================================
  # ACTIVE STORAGE
  # ============================================================
  # Em produção use um serviço externo (amazon/google/azure). FS efêmero some a cada deploy.
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

  default_host = ENV.fetch("APP_HOST", "www.cargaclick.com.br")
  default_proto = ENV.fetch("APP_PROTOCOL", "https")

  config.action_mailer.default_url_options = {
    host:     default_host,
    protocol: default_proto
  }
  config.action_mailer.asset_host = "#{default_proto}://#{default_host}"
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

  # Dados adicionais (derivados do controller)
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

  # Dados do evento (usa o Time correto para evitar "1970-...")
  config.lograge.custom_options = lambda do |event|
    params = event.payload[:params]
    {
      time:       event.time.utc.iso8601,
      request_id: event.payload[:request_id],
      params:     params ? params.except("controller", "action", "format") : {}
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
  # Para páginas de erro customizadas, descomente:
  # config.exceptions_app = routes
end
# EOF
