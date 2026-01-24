# frozen_string_literal: true

require "active_support/core_ext/integer/time"

Rails.application.configure do
  # =========================================================
  # CONFIGURAÇÕES BÁSICAS
  # =========================================================
  config.cache_classes = true
  config.eager_load = true
  config.consider_all_requests_local = false
  config.action_controller.perform_caching = true

  config.require_master_key = false

  # =========================================================
  # LOGS
  # =========================================================
  config.log_level = :info
  config.log_tags = [:request_id]

  # =========================================================
  # I18N
  # =========================================================
  config.i18n.fallbacks = true
  config.active_support.deprecation = :notify

  # =========================================================
  # ASSETS
  # =========================================================
  config.assets.compile = false
  config.public_file_server.enabled = ENV["RAILS_SERVE_STATIC_FILES"].present?

  # =========================================================
  # SSL / HTTPS  (🔥 CORREÇÃO DEFINITIVA)
  # =========================================================
  # ➜ LOCAL:   FORCE_SSL=false
  # ➜ RENDER:  FORCE_SSL=true
  config.force_ssl = ENV["FORCE_SSL"] == "true"
  config.assume_ssl = false

  # =========================================================
  # STORAGE
  # =========================================================
  config.active_storage.service = :local

  # =========================================================
  # ACTION MAILER
  # =========================================================
  config.action_mailer.perform_caching = false

  # =========================================================
  # INTERNATIONALIZATION
  # =========================================================
  config.i18n.default_locale = :"pt-BR"
end
