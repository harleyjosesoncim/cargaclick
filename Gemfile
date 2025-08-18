# frozen_string_literal: true
source "https://rubygems.org"

ruby "3.2.4"

# Framework
gem "rails", "~> 7.1.5", ">= 7.1.5.1"

# Servidor web
gem "puma", "~> 6.4"

# Banco de dados
gem "pg", "~> 1.5", "< 2.0"

# Assets / Front-end
gem "sprockets-rails", "~> 3.5"
gem "jsbundling-rails", "~> 1.3"
gem "cssbundling-rails", "~> 1.4"
gem "turbo-rails", "~> 2.0"
gem "stimulus-rails", "~> 1.3"

# Autenticação e segurança
gem "devise", "~> 4.9"
gem "bcrypt", "~> 3.1"

# Uploads e SEO
gem "image_processing", "~> 1.12"
gem "sitemap_generator", "~> 6.3"

# Integrações
gem "mercadopago-sdk", "~> 2.0"

# Agendamento (cron)
gem "whenever", "~> 1.0", require: false

# Performance e CORS
gem "bootsnap", "~> 1.16", require: false
# Rails 7.1 usa Rack 3 → precisa rack-cors v3 (NÃO duplique esta gem em outra linha)
gem "rack-cors", "~> 3.0"

# Monitoramento (produção)
group :production do
  # 10.x não existe no RubyGems; use 9.x estável
  gem "newrelic_rpm", ">= 9.0", "< 10.0"
  gem "sentry-ruby",  "~> 5.17"
  gem "sentry-rails", "~> 5.17"
end

# Desenvolvimento e Teste
group :development, :test do
  gem "dotenv-rails", "~> 3.1"
  gem "debug", "~> 1.9", platforms: [:mri]
end

group :development do
  gem "web-console", "~> 4.2"
  gem "listen", "~> 3.8"
end

group :test do
  gem "minitest", "~> 5.25"
  # gem "rspec-rails", "~> 6.1"
end

# Compatibilidade com Windows
gem "tzinfo-data", platforms: %i[mingw x64_mingw mswin]

# Admin (opcional)
# gem "rails_admin", "~> 3.2"
