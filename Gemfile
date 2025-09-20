# frozen_string_literal: true

source "https://rubygems.org"

ruby "3.2.4"

# === Core Rails & Database ===
gem "rails", "~> 7.1.5", ">= 7.1.5.1"
gem "pg", "~> 1.5"
gem "puma", "~> 6.6"
gem "bootsnap", ">= 1.17", require: false
gem "json", ">= 2.6"

# === Frontend & Assets ===
gem "tailwindcss-rails", "~> 3.0" # Corrigido para a versão compatível com suas gems instaladas
gem "turbo-rails", "~> 2.0"
gem "sprockets-rails", "~> 3.4"
gem "sassc-rails", "~> 2.1"

# === Utilities & Business Logic ===
gem "activeadmin"
gem "devise", "~> 4.9"
gem "mercadopago-sdk", "~> 2.3", require: "mercadopago"
gem "image_processing", "~> 1.2"
gem "sitemap_generator"
gem "secure_headers", "~> 6.5"
gem "rails-i18n", "~> 7.0"
gem "terser"

# === Production Environment ===
group :production do
  gem "lograge", "~> 0.14"
  gem "puma_worker_killer", "~> 0.3"
  gem "rack-attack", "~> 6.7"
  gem "rack-timeout", "~> 0.7"
end

# === Development Environment ===
group :development do
  gem "dotenv-rails", "~> 3.1"
  gem "debug", "~> 1.11"
  gem "web-console", "~> 4.2"
  gem "listen", "~> 3.9"
  gem "bindex", "~> 0.8"
  gem "rb-fsevent", "~> 0.11", require: false
  gem "rb-inotify", "~> 0.11", require: false
end

# === Test Environment ===
group :test do
  gem "rspec-rails", "~> 6.0"
  gem "factory_bot_rails"
  gem "faker"
  gem "capybara"
  gem "selenium-webdriver"
end