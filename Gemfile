# frozen_string_literal: true
source "https://rubygems.org"

ruby "3.2.4"

# Framework
gem "rails", "~> 7.1.5", ">= 7.1.5.1"

# Web server
gem "puma", "~> 6.4"

# Banco de dados
gem "pg", ">= 1.5", "< 2.0"

# Pipeline de assets (necessário para tasks como assets:precompile)
gem "sprockets-rails", "~> 3.5"

# Front-end (Rails 7)
gem "turbo-rails"
gem "stimulus-rails"
gem "jsbundling-rails"   # esbuild/rollup/webpack
gem "cssbundling-rails"  # Tailwind/PostCSS/Sass

# Autenticação / Uploads / SEO
gem "devise", "~> 4.9"
gem "bcrypt", ">= 3.1"             # usado pelo devise/has_secure_password
gem "image_processing", "~> 1.12"
gem "sitemap_generator", "~> 6.3"

# Integrações / Pagamentos
gem "mercadopago-sdk"              # Mercadopago::SDK (SDK oficial)

# Agendamento via cron (se usar VPS/cron do SO)
gem "whenever", require: false

# CORS + performance
gem "rack-cors"
gem "bootsnap", ">= 1.16.0", require: false

# Admin (OPCIONAL). Ative se for usar /rails_admin
# gem "rails_admin", "~> 3.1"

group :development, :test do
  gem "dotenv-rails"               # carrega .env* fora de produção
end

group :development do
  gem "web-console"
  gem "listen", "~> 3.8"
  gem "debug", platforms: [:mri]
end

group :test do
  gem "minitest", "~> 5.25"
  # gem "rspec-rails", "~> 6.1"
end

# Compat Windows
gem "tzinfo-data", platforms: %i[mingw x64_mingw mswin]
