# config/application.rb
require_relative "boot"
require "rails/all"

# Carrega gems por grupos (default do Rails)
Bundler.require(*Rails.groups)

module Cargaclick
  class Application < Rails::Application
    config.load_defaults 7.1

    # Autoload do diretório lib/ (Rails 7.1+)
    config.autoload_lib(ignore: %w[assets tasks])

    # Build/CI sem exigir master key (Render injeta secrets em runtime)
    config.require_master_key = false

    # Não inicializar a app no precompile dos assets
    config.assets.enabled = true
    config.assets.version = "1.0"


    # Não coloca Rack::Attack aqui; o initializer já faz isso no momento certo.
    # (Se você achar alguma linha como `config.middleware.use Rack::Attack` remova)
  end
end
