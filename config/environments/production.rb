# config/environments/production.rb
# frozen_string_literal: true

require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Boot
  config.enable_reloading = false
  config.eager_load       = true

  # ===== Erros / Cache =====
  # Ligue stack trace temporariamente com: RAILS_CONSIDER_ALL_REQUESTS_LOCAL=true
  config.consider_all_requests_local = ENV["RAILS_CONSIDER_ALL_REQUESTS_LOCAL"] == "true"
  # Cache store: usa Redis se REDIS_URL existir (recomendado p/ Rack::Attack em múltiplos workers/instâncias)
  if ENV["REDIS_URL"].present?
    config.cache_store = :redis_cache_store, {
      url: ENV["REDIS_URL"],
      connect_timeout: 5,
      read_timeout: 1,
      write_timeout: 1,
      reconnect_attempts: 1,
      error_handler: ->(method:, returning:, exception:) {
        Rails.logger.warn("Redis cache error #{method} -> #{exception.class}: #{exception.message}")
      }
    }
  else
    config.cache_store = :memory_store, { size: 128.megabytes }
  end
  config.action_controller.perform_caching = true

  # ===== Arquivos estáticos (Render/Heroku/K8s) =====
  serve_static = ENV["RAILS_SERVE_STATIC_FILES"].present? || ENV["RENDER"].present? || ENV["HEROKU"].present?
  config.public_file_server.enabled = serve_static
  if serve_static
    max = 1.year.to_i
    config.public_file_server.headers = {
      "Cache-Control"     => "public, max-age=#{max}",
      "Surrogate-Control" => "max-age=#{max}"
    }
  end

  # ===== Assets =====
  config.assets.compile        = false
  config.assets.css_compressor = nil # Tailwind/Esbuild fazem o papel

  # ===== Active Storage =====
  # Em Render, disco é efêmero. Use serviço externo em produção real (S3, GCS):
  config.active_storage.service = ENV.fetch("ACTIVE_STORAGE_SERVICE", "local").to_sym

  # ===== Segurança =====
  force_ssl = ENV.fetch("FORCE_SSL", "true") == "true"
  config.force_ssl  = force_ssl
  config.ssl_options = { hsts: { expires: 2.years, preload: true, subdomains: true } } if force_ssl
  config.action_controller.forgery_protection_origin_check = true
  config.action_dispatch.use_cookies_with_metadata         = true

  # ===== Log =====
  config.log_level     = ENV.fetch("RAILS_LOG_LEVEL", "info").to_sym
  config.log_tags      = [:request_id, ->(req) { "ip=#{req.ip}" }]
  config.log_formatter = ::Logger::Formatter.new

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # Lograge (JSON enxuto)
  if defined?(Lograge)
    config.lograge.enabled = true
    config.lograge.formatter = Lograge::Formatters::Json.new
    config.lograge.custom_payload do |controller|
      {
        request_id: controller.request.request_id,
        user_id: (controller.respond_to?(:current_user) && controller.current_user&.id),
      }
    end
    config.lograge.custom_options = lambda { |event|
      {
        params: event.payload[:params].slice("controller", "action", "format"),
        time: Time.now.utc.iso8601
      }
    }
  end

  # ===== I18n / Deprecações =====
  config.i18n.fallbacks = true
  config.active_support.report_deprecations = false

  # ===== DB =====
  config.active_record.dump_schema_after_migration = false

  # ===== Host e URLs canônicas =====
  canonical_host = ENV.fetch("APP_HOST", "www.cargaclick.com.br")
  allowed_hosts  = ENV.fetch("ALLOWED_HOSTS", "cargaclick.com.br,www.cargaclick.com.br,localhost,127.0.0.1")
                    .split(",").map(&:strip).reject(&:blank?)
  (allowed_hosts + [canonical_host]).uniq.each { |h| config.hosts << h }
  config.hosts << /\A.*\.onrender\.com\z/ # Render
  # Permite /up sem verificação de host
  config.host_authorization = { exclude: ->(req) { req.path == "/up" } }

  # ===== Mailer / URLs geradas =====
  config.action_mailer.perform_caching     = false
  config.action_mailer.default_url_options = { host: canonical_host, protocol: "https" }
  config.action_mailer.asset_host          = "https://#{canonical_host}"
  # Se usar SMTP em produção, configure via ENV:
  # config.action_mailer.delivery_method = :smtp
  # config.action_mailer.smtp_settings = { address: ..., user_name: ..., password: ..., ... }

  # ===== URL helpers (ex.: *_url) =====
  Rails.application.routes.default_url_options[:host]     = canonical_host
  Rails.application.routes.default_url_options[:protocol] = "https"

  # ===== Compressão HTTP =====
  # Pode reduzir bastante o tráfego. Ative via ENV para evitar duplicidade com proxy/CDN.
  if ENV["ENABLE_DEFLATE"] == "true"
    config.middleware.use Rack::Deflater
  end

  # ===== Exceptions =====
  # nil => usa as páginas estáticas em /public/404.html, 422.html, 500.html
  config.exceptions_app = nil
end

