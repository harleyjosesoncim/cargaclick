# frozen_string_literal: true

source "https://rubygems.org"
ruby "3.2.4"

# === Core Rails & Database ===
gem "rails", "~> 7.1.5", ">= 7.1.5.2"
gem "pg", "~> 1.5"
gem "puma", "~> 6.6"
gem "bootsnap", ">= 1.17", require: false
gem "redis", "~> 5.0" # usado se REDIS_URL estiver definido (cache/sidekiq)

# === Frontend & Assets ===
gem "importmap-rails"               # para Turbo/JS sem Node em runtime
gem "turbo-rails", "~> 2.0"
gem "tailwindcss-rails", "~> 2.6"   # estável com Rails 7.1
gem "sprockets-rails", "~> 3.4"
gem "sassc-rails", "~> 2.1"
gem "terser"                        # compressor JS do Sprockets

# === Utilities & Business Logic ===
gem "activeadmin"
gem "devise", "~> 4.9"
gem "mercadopago-sdk", "~> 2.3", require: "mercadopago"
gem "image_processing", "~> 1.12"
gem "sitemap_generator"
gem "secure_headers", "~> 6.5"
gem "rails-i18n", "~> 7.0"

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

# Windows (opcional, se rodar fora do WSL)
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]
