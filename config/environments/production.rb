# config/environments/production.rb
require "active_support/core_ext/integer/time"

Rails.application.configure do
  config.enable_reloading = false
  config.eager_load = true

  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  # Servir estáticos quando a plataforma definir a flag
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  # Assets
  # config.assets.css_compressor = :sass
  config.assets.compile = false

  # Uploads
  config.active_storage.service = :local

  # SSL (Render/Proxy) + cookies seguros
  config.assume_ssl = true
  config.force_ssl  = true

  # Logs
  config.logger = ActiveSupport::Logger.new(STDOUT)
    .tap  { |l| l.formatter = ::Logger::Formatter.new }
    .then { |l| ActiveSupport::TaggedLogging.new(l) }
  config.log_tags  = [:request_id]
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info")

  # Mailer e URLs padrão -> sem www
  config.action_mailer.perform_caching = false
  config.action_mailer.default_url_options = { host: "cargaclick.com.br", protocol: "https" }
  config.action_mailer.asset_host = "https://cargaclick.com.br"

  config.i18n.fallbacks = true
  config.active_support.report_deprecations = false
  config.active_record.dump_schema_after_migration = false

  # Hosts permitidos
  config.hosts << "cargaclick.com.br"       # canônico
  config.hosts << "www.cargaclick.com.br"   # aceita, mas redirecionaremos
  config.hosts << "cargaclick.onrender.com" # útil em testes
  config.hosts << ENV["RENDER_EXTERNAL_HOSTNAME"] if ENV["RENDER_EXTERNAL_HOSTNAME"].present?

  # Health check
  config.host_authorization = { exclude: ->(req) { req.path == "/up" } }

  # Garante helpers/redirects com domínio canônico
  config.after_initialize do
    Rails.application.routes.default_url_options = {
      host: "cargaclick.com.br",
      protocol: "https"
    }
  end
end
