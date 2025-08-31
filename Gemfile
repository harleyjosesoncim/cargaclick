source "https://rubygems.org"

ruby "3.2.4"

# --- Core ---
gem "rails", "~> 7.1.5", ">= 7.1.5.1"
gem "pg", ">= 1.5", "< 2.0"
gem "puma", "~> 6.4"
gem "bootsnap", ">= 1.17", require: false

# --- Frontend / Hotwire ---
gem "turbo-rails"
gem "tailwindcss-rails"
gem "sprockets-rails", "~> 3.4"
gem "sassc-rails", "~> 2.1"

# --- Autenticação ---
gem "devise"

# --- Uploads (caso use ActiveStorage) ---
gem "image_processing", "~> 1.2"

# --- Internacionalização (opcional mas recomendado) ---
gem "rails-i18n", "~> 7.0"

# --- Produção ---
group :production do
  gem "lograge", "~> 0.14"           # logs estruturados
  gem "puma_worker_killer", "~> 0.3" # recicla workers com leak de memória
  gem "rack-attack", "~> 6.7"        # rate limiting
  gem "rack-timeout", "~> 0.7"       # evita requests travados
  # gem "rails_12factor"              # se usar Heroku/Render (assets + logs)
  # gem "secure_headers"              # segurança extra (CSP/HSTS)
end

# --- Desenvolvimento e Teste ---
group :development, :test do
  gem "dotenv-rails", "~> 3.1"
  gem "debug", "~> 1.11"
  gem "web-console", "~> 4.2"
  gem "listen", "~> 3.9"
  gem "bindex", "~> 0.8"

  # Testes (boa prática)
  gem "rspec-rails", "~> 6.0"
  gem "factory_bot_rails"
  gem "faker"
end

# --- Desenvolvimento (watchers por SO) ---
group :development do
  gem "rb-fsevent", "~> 0.11"   # funciona só em macOS, no Linux ele é ignorado
  gem "rb-inotify", "~> 0.11"   # funciona só em Linux, no macOS ele é ignorado
end
# --- Teste ---

