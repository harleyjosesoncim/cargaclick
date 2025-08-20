# config/application.rb
require_relative "boot"
require "rails/all"

Bundler.require(*Rails.groups)

module Cargaclick
  class Application < Rails::Application
    # Rails 7.1
    config.load_defaults 7.1

    # Autoload de lib/ (Rails 7.1+)
    config.autoload_lib(ignore: %w[assets tasks])

    # CI/Render sem master key (Render injeta secrets em runtime)
    config.require_master_key = false

    # Assets
    config.assets.enabled = true
    config.assets.version = "1.0"
    config.assets.initialize_on_precompile = false

    # Timezone (opcional; ajuste se desejar)
    # config.time_zone = "America/Sao_Paulo"

    # NÃO monte Rack::Attack aqui; o initializer cuida disso.
  end
end
