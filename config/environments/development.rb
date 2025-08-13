Rails.application.configure do
  # Settings specified here will take precedence over those in config/application.rb.

  # Dev env: recarrega código e mostra erros completos
  config.cache_classes = false
  config.eager_load = false
  config.consider_all_requests_local = true

  # Deprecations: só loga (não levanta exception)
  config.active_support.deprecation = :log
  config.active_support.report_deprecations = true
  config.active_support.disallowed_deprecation = nil
  config.active_support.disallowed_deprecation_warnings = []

  # …mantenha aqui as outras configs que você já tinha…
end
