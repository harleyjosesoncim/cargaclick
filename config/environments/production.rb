# frozen_string_literal: true

require "active_support/core_ext/integer/time"

Rails.application.configure do
  # Boot
  config.enable_reloading = false
  config.eager_load       = true
  config.require_master_key = true

  # Erros / Cache
  config.consider_all_requests_local       = false
  config.action_controller.perform_caching = true
  config.cache_store = :memory_store, { size: 64.megabytes }

  # Arquivos estáticos (Render/Heroku/K8s)
  serve_static = ENV["RAILS_SERVE_STATIC_FILES"].present? || ENV["RENDER"].present? || ENV["HEROKU"].present?
  config.public_file_server.enabled = serve_static
  if serve_static
    max = 1.year.to_i
    config.public_file_server.headers = {
      "Cache-Control"     => "public, max-age=#{max}",
      "Surrogate-Control" => "max-age=#{max}"
    }
  end
# config/environments/production.rb
Rails.application.configure do
  # …
  config.assets.css_compressor = nil   # evita SassC quebrar com CSS4 (rgb/…)
  # opcional: config.assets.js_compressor = nil
  # …
end

  # SSL opcional via ENV
  config.force_ssl = ENV["FORCE_SSL"] == "1"

  # Log
  config.log_level = ENV.fetch("RAILS_LOG_LEVEL", "info").to_sym
  config.log_tags  = [:request_id, :remote_ip]

  if ENV["RAILS_LOG_TO_STDOUT"].present?
    logger           = ActiveSupport::Logger.new($stdout)
    logger.formatter = ::Logger::Formatter.new
    config.logger    = ActiveSupport::TaggedLogging.new(logger)
  end

  # I18n
  config.i18n.fallbacks = true

  # Active Storage (ajuste se usar S3/GCS)
  config.active_storage.service = ENV.fetch("ACTIVE_STORAGE_SERVICE", "local").to_sym

  # Mailer (só configura se tiver host)
  mail_host = ENV["MAILER_HOST"]
  if mail_host.present?
    proto = ENV["MAILER_PROTOCOL"] || "https"
    config.action_mailer.default_url_options = { host: mail_host, protocol: proto }
    config.action_mailer.asset_host          = "#{proto}://#{mail_host}"
  end
  config.action_mailer.perform_caching       = false
  config.action_mailer.raise_delivery_errors = false

  # Hosts permitidos
  app_host = ENV["APP_HOST"]
  config.hosts << app_host if app_host.present?
  if (csv = ENV["ALLOWED_HOSTS"]).present?
    csv.split(",").map(&:strip).reject(&:empty?).each { |h| config.hosts << h }
  end

  # Rack::Attack (se presente)
  config.middleware.use Rack::Attack if defined?(Rack::Attack)

  # Lograge (se presente)
  if defined?(Lograge)
    config.lograge.enabled   = true
    config.lograge.formatter = Lograge::Formatters::Json.new

    # Campos extras por request
    config.lograge.custom_payload do |controller|
      {
        request_id: controller.request.request_id,
        user_id:    (controller.respond_to?(:current_user) ? controller.current_user&.id : nil),
        remote_ip:  controller.request.remote_ip,
        params:     controller.request.filtered_parameters.except("controller", "action")
      }
    end

    # Campos extras por evento
    config.lograge.custom_options = lambda do |event|
      {
        time:      (event.time.respond_to?(:iso8601) ? event.time.iso8601 : event.time),
        method:    event.payload[:method],
        path:      event.payload[:path],
        status:    event.payload[:status],
        duration:  event.duration,
        exception: event.payload[:exception_object]&.class&.name,
        exception_message: event.payload[:exception_object]&.message
      }
    end
  end

  # Deprecações
  config.active_support.report_deprecations = false

  # Não dumpa schema após migrações
  config.active_record.dump_schema_after_migration = false
end
