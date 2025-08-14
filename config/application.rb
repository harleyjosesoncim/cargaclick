# config/application.rb
require_relative "boot"
require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)
# Dotenv em dev/test é carregado pelo Bundler; não precisa forçar aqui.
# Dotenv::Railtie.load

module CargaClick
  class Application < Rails::Application
    # Rails 7.1 (compatível com seu Gemfile 7.1.5.1)
    config.load_defaults 7.1

    # Autoload do diretório lib/, ignorando subpastas não-Ruby
    config.autoload_lib(ignore: %w[assets tasks])

    # Não exigir master key no build (Render injeta secrets em runtime)
    config.require_master_key = false

    # Evita rodar initializers durante assets:precompile
    config.assets.initialize_on_precompile = false

    # Não gerar system tests
    config.generators.system_tests = nil

    # Opcional:
    # config.time_zone = "Brasilia"
    # config.eager_load_paths << Rails.root.join("extras")
  end
end
