Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true
  # ... outras configs que estavam nele
  # Mostra exatamente quem chama `Rails.application.secrets`
config.active_support.deprecation = :raise
config.active_support.report_deprecations = true

end
