# config/initializers/assets.rb
# frozen_string_literal: true

Rails.application.config.assets.version = "1.0"

# Inclui a pasta dos bundles gerados (esbuild/tailwind)
Rails.application.config.assets.paths << Rails.root.join("app/assets/builds")

# Garante a pré-compilação de folhas avulsas além do application.css
Rails.application.config.assets.precompile += %w[
  leaflet.css
]
