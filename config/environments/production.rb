# config/environments/production.rb
# frozen_string_literal: true

require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Boot
  config.enable_reloading = false
  config.eager_load       = true

  # Erros / Cache
  config.consider_all_requests_local         = false
  config.action_controller.perform_caching   = true
  config.cache_store                         = :memory_store

  # Arquivos estáticos (Render/Heroku/K8s)
  serve_static = ENV["RAILS_SERVE_STATIC_FILES"].present? || ENV["RENDER"].present? || ENV["HEROKU"].present?
  config.public_file_server.enabled = serve_static
  if serve_static
    max = 1.year.to_i
    config.public_file_server.headers = {
      "Cache-Control"    => "public, max-age=#{max}",
      "Surrogate-Control" => "max-age=#{max}"
    }
  end

  # Assets (pré-compilados; esbuild/tailwind geram em app/assets/builds)
  config.assets.compile        = false
  config.assets.css_compressor = nil

  # Active Storage (mude p/ :amazon, :google etc. em produção real)
  config.active_storage.service = ENV.fetch("ACTIVE_STORAGE_SERVICE", "local").to_sym

  # Segurança
  config.force_ssl  = ENV.fetch("FORCE_SSL", "true") == "true"
  config.ssl_options = { hsts: { expires: 2.years, preload: true, subdomains: true } }
  config.action_controller.forgery_protection_origin_check = true
  config.action_dispatch.use_cookies_with_metadata         = true

  # Log
  config.log_level    = ENV.fetch("RAILS_LOG_LEVEL", "info").to_sym
  config.log_tags     = [:request_id, ->(req) { "ip=#{req.ip}" }]
  config.log_formatter = ::Logger::Formatter.new
  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger = ActiveSupport::Logger.new($stdout)
    logger.formatter = config.log_formatter
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # I18n / Deprecações
  config.i18n.fallbacks                 = true
  config.active_support.report_deprecations = false

  # DB
  config.active_record.dump_schema_after_migration = false

  # ===== Host e URLs canônicas =====
  canonical_host = ENV.fetch("APP_HOST", "www.cargaclick.com.br")
  allowed_hosts  = ENV.fetch("ALLOWED_HOSTS", "cargaclick.com.br,www.cargaclick.com.br,localhost,127.0.0.1")
                    .split(",").map(&:strip).reject(&:blank?)
  (allowed_hosts + [canonical_host]).uniq.each { |h| config.hosts << h }
  config.hosts << /\A.*\.onrender\.com\z/
  config.host_authorization = { exclude: ->(req) { req.path == "/up" } }

  # Mailer / URLs geradas
  config.action_mailer.perform_caching   = false
  config.action_mailer.default_url_options = { host: canonical_host, protocol: "https" }
  config.action_mailer.asset_host          = "https://#{canonical_host}"

  # Helpers de URL (ex.: *_url)
  Rails.application.routes.default_url_options[:host]     = canonical_host
  Rails.application.routes.default_url_options[:protocol] = "https"

  # Exceptions: servir páginas estáticas /public/404.html, 422.html, 500.html
  # (deixe nil para usar o comportamento padrão do Rails)
  config.exceptions_app = nil
end
