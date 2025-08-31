# config/environment.rb
# frozen_string_literal: true

# Carrega a aplicação Rails
require_relative "application"

# Inicializa a aplicação Rails
Rails.application.initialize!

# 👉 Se precisar carregar configs adicionais (por exemplo: Rack::Attack, Sentry, Sidekiq, etc.)
# você pode criar arquivos em config/initializers/*.rb
# e eles serão carregados automaticamente pelo Rails.

# Exemplo: config/initializers/rack_attack.rb
# return unless defined?(Rack::Attack)
# Rack::Attack.enabled = ENV.fetch("RACK_ATTACK_ENABLED", "true") == "true"
