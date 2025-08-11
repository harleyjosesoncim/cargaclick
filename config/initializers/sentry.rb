if ENV['SENTRY_DSN'].present?
  Sentry.init do |config|
    config.dsn = ENV['SENTRY_DSN']
    config.enabled_environments = %w[production]
    config.environment = ENV.fetch('SENTRY_ENV', Rails.env)
    config.breadcrumbs_logger = [:active_support_logger, :http_logger]

    # Performance (ajuste as taxas se quiser)
    config.traces_sample_rate   = ENV.fetch('SENTRY_TRACES_SAMPLE_RATE', '0.2').to_f
    config.profiles_sample_rate = ENV.fetch('SENTRY_PROFILES_SAMPLE_RATE', '0.0').to_f

    # Filtra parâmetros sensíveis
    filter = ActiveSupport::ParameterFilter.new(Rails.application.config.filter_parameters)
    config.before_send = lambda do |event, _hint|
      if event&.request&.data
        event.request.data = filter.filter(event.request.data)
      end
      event
    end
  end
end
