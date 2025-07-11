require_relative "boot"

require "rails/all"

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

module CargaClick
  class Application < Rails::Application
    # Inicializa as configurações padrão para a versão do Rails usada:
    config.load_defaults 6.1

    # (Opcional) Defina o fuso horário padrão, se desejar:
    # config.time_zone = "America/Sao_Paulo"

    # (Opcional) Caminhos adicionais para carregar arquivos (pode remover se não usar!)
    # config.eager_load_paths << Rails.root.join("lib")

    # NÃO coloque config.api_only = true aqui! Isso quebra devise.

    # Não gere arquivos de teste de sistema (system tests)
    config.generators.system_tests = nil

    # NÃO coloque config.autoload_lib - esse método não existe no Rails puro!
  end
end

