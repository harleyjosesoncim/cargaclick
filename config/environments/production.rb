require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Boot
  config.enable_reloading = false
  config.eager_load = true

  # Erros e cache
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true
  config.cache_store = :memory_store

  # Arquivos estáticos e assets
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?
  if config.public_file_server.enabled
    config.public_file_server.headers = {
      "Cache-Control" => "public, max-age=#{1.year.to_i}"
    }
  end
  config.assets.compile = false
  # config.assets.css_compressor = :sass

  # Uploads (em PaaS o disco é efêmero; use S3 em prod real)
  config.active_storage.service = :local

  # SSL/Proxy (Render/Cloudflare)
  config.force_ssl = true
  config.assume_ssl = true if config.respond_to?(:assume_ssl)

  # Logs (STDOUT p/ plataforma)
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")
  base_logger = Logger.new($stdout)
  base_logger.formatter = Logger::Formatter.new
  config.logger = ActiveSupport::TaggedLogging.new(base_logger)
  config.log_tags = [:request_id]
  config.log_formatter = ::Logger::Formatter.new

  # I18n / Deprecações / DB
  config.i18n.fallbacks = true
  config.active_support.report_deprecations = false
  config.active_record.dump_schema_after_migration = false

  # Mailer e URLs padrão (domínio canônico, sem www)
  host = "cargaclick.com.br"
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { host: host, protocol: "https" }
  config.action_mailer.asset_host = "https://#{host}"

  # Hosts permitidos
  config.hosts << host
  config.hosts << "www.#{host}"
  config.hosts << "cargaclick.onrender.com"
  config.hosts << ENV["RENDER_EXTERNAL_HOSTNAME"] if ENV["RENDER_EXTERNAL_HOSTNAME"].present?

  # Health check do Render
  config.host_authorization = { exclude: ->(req) { req.path == "/up" } }

  # URL helpers (url_for, *_url) usam o domínio canônico
  config.after_initialize do
    Rails.application.routes.default_url_options = {
      host: host,
      protocol: "https"
    }
  end
end
