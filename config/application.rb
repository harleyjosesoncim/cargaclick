# frozen_string_literal: true

# config/application.rb
require_relative "boot"
require "rails/all"

Bundler.require(*Rails.groups)
require "dotenv/load" if defined?(Dotenv)

module Cargaclick
  class Application < Rails::Application
    # =====================================================
    # Rails version / defaults
    # =====================================================
    config.load_defaults 7.1

    # =====================================================
    # Zeitwerk / Autoload / Eager load
    # =====================================================
    # Rails 7.1 NÃO garante autoload de app/services em projetos complexos
    # (como este, com múltiplos namespaces de serviços).
    # Estas linhas resolvem definitivamente o problema:
    config.autoload_paths << Rails.root.join("app/services")
    config.eager_load_paths << Rails.root.join("app/services")

    # Autoload explícito de lib/ (Rails 7.1+)
    config.autoload_lib(ignore: %w[assets tasks])

    # =====================================================
    # Secrets / CI / Deploy (Render / Fly / Docker)
    # =====================================================
    # Master key desabilitada porque os secrets são injetados
    # via ENV no ambiente de deploy
    config.require_master_key = false

    # =====================================================
    # Assets / Front-end
    # =====================================================
    config.assets.enabled = true
    config.assets.version = "1.0"

    # Evita problemas de pré-compilação em CI
    config.assets.initialize_on_precompile = false

    # Evita erro com rgb() no Tailwind + SassC
    config.assets.css_compressor = nil

    # =====================================================
    # Encoding / I18n
    # =====================================================
    config.encoding = "utf-8"

    config.i18n.default_locale = :"pt-BR"
    config.i18n.available_locales = [:"pt-BR", :en]

    # =====================================================
    # Timezone
    # =====================================================
    config.time_zone = "America/Sao_Paulo"
    config.active_record.default_timezone = :local
    config.active_record.time_zone_aware_types = [:datetime, :time]

    # =====================================================
    # Generators (código limpo)
    # =====================================================
    config.generators do |g|
      g.stylesheets false
      g.javascripts false
      g.helper false
      g.test_framework :rspec, fixture: false
    end

    # =====================================================
    # Segurança / Middleware
    # =====================================================
    # Rack::Attack NÃO deve ser montado aqui
    # Ele é inicializado via config/initializers
  end
end
