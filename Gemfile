# frozen_string_literal: true
source "https://rubygems.org"

ruby "3.2.4"

# Framework
gem "rails", "~> 7.1.5", ">= 7.1.5.1"

# Web server
gem "puma", "~> 6.4"

# Banco de dados
gem "pg", ">= 1.5", "< 2.0"

# Front-end (Rails 7 com bundlers JS/CSS)
gem "turbo-rails"
gem "stimulus-rails"
gem "jsbundling-rails"   # esbuild/rollup/webpack
gem "cssbundling-rails"  # Tailwind/PostCSS/Sass

# Autenticação
gem "devise", "~> 4.9"

# Active Storage / imagens
gem "image_processing", "~> 1.12"

# SEO: geração de sitemap
gem "sitemap_generator", "~> 6.3"

# Agendador via crontab (não auto-requer)
gem "whenever", require: false

# CORS (se expor API / front separado)
gem "rack-cors"

# Performance
gem "bootsnap", ">= 1.16.0", require: false

# Variáveis de ambiente (apenas dev/test)
gem "dotenv-rails", groups: [:development, :test]

# Observabilidade (opcional)
# gem "sentry-ruby"

group :development do
  gem "web-console"
  gem "listen", "~> 3.8"
  gem "debug", platforms: [:mri]
end

group :test do
  gem "minitest", "~> 5.25" # troque por rspec-rails se preferir
  # gem "rspec-rails", "~> 6.1"
end

# Compat Windows
gem "tzinfo-data", platforms: %i[mingw x64_mingw mswin]

gem "sprockets-rails", "~> 3.5"
