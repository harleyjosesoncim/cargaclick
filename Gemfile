# frozen_string_literal: true

source "https://rubygems.org"

ruby "3.2.4"
gem "json", ">= 2.6"

# --- Núcleo do Rails ---
gem "rails", "~> 7.1.5", ">= 7.1.5.1"
gem "pg", ">= 1.5", "< 2.0"            # PostgreSQL
gem "puma", "~> 6.6"                   # servidor web
gem "bootsnap", ">= 1.17", require: false # acelera boot da app

# --- Integração Mercado Pago (gem correto e compatível) ---
gem "mercadopago-sdk", "~> 2.0"

# --- Frontend / Hotwire ---
gem "turbo-rails"
gem "tailwindcss-rails", "~> 4.1"
gem "sprockets-rails", "~> 3.4"
gem "sassc-rails", "~> 2.1"

# --- Autenticação ---
gem "devise"

# --- Uploads / ActiveStorage ---
gem "image_processing", "~> 1.2"

# --- Internacionalização ---
gem "rails-i18n", "~> 7.0"

# --- Produção ---
group :production do
  gem "lograge", "~> 0.14"
  gem "puma_worker_killer", "~> 0.3"
  gem "rack-attack", "~> 6.7"
  gem "rack-timeout", "~> 0.7"
end

# --- Desenvolvimento & Teste ---
group :development, :test do
  gem "dotenv-rails", "~> 3.1"
  gem "debug", "~> 1.11"
  gem "web-console", "~> 4.2"
  gem "listen", "~> 3.9"
  gem "bindex", "~> 0.8"

  # Testes
  gem "rspec-rails", "~> 6.0"
  gem "factory_bot_rails"
  gem "faker"
end

# --- Desenvolvimento (SO específicos) ---
group :development do
  gem "rb-fsevent", "~> 0.11", require: false
  gem "rb-inotify", "~> 0.11", require: false
end

