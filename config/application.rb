# config/application.rb
require_relative "boot"
require "rails/all"

Bundler.require(*Rails.groups)
require "dotenv/load" if defined?(Dotenv)

module Cargaclick
  class Application < Rails::Application
    # Rails 7.1
    config.load_defaults 7.1

    # Autoload de lib/ (Rails 7.1+)
    config.autoload_lib(ignore: %w[assets tasks])

    # CI/Render sem master key (Render injeta secrets em runtime)
    config.require_master_key = false

    # === Assets =====================================================
    config.assets.enabled = true
    config.assets.version = "1.0"
    config.assets.initialize_on_precompile = false

    # ⚡ Importante: evita erro com rgb() no Tailwind + SassC
    config.assets.css_compressor = nil

    # Encoding padrão
    config.encoding = "utf-8"

    # Localização
    config.i18n.default_locale = :"pt-BR"
    config.i18n.available_locales = [:"pt-BR", :en]

    # Timezone
    config.time_zone = "America/Sao_Paulo"
    config.active_record.default_timezone = :local
    config.active_record.time_zone_aware_types = [:datetime, :time]

    # Geração de código limpa
    config.generators do |g|
      g.stylesheets false
      g.javascripts false
      g.helper false
      g.test_framework :rspec, fixture: false
    end

    # NÃO monte Rack::Attack aqui; o initializer cuida disso.
  end
end
