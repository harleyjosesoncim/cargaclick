# frozen_string_literal: true

source "https://rubygems.org"

ruby "3.2.4"

# --- Núcleo do Rails ---
gem "rails", "~> 7.1.5", ">= 7.1.5.1"
gem "pg", ">= 1.5", "< 2.0"      # PostgreSQL
gem "puma", "~> 6.4"             # Servidor web
gem "bootsnap", ">= 1.17", require: false # acelera boot da app

# --- Frontend / Hotwire ---
gem "turbo-rails"                # navegação Turbo
gem "tailwindcss-rails"          # TailwindCSS integrado
gem "sprockets-rails", "~> 3.4"  # pipeline de assets
gem "sassc-rails", "~> 2.1"      # compilador CSS

# --- Autenticação ---
gem "devise"                     # autenticação de usuários

# --- Uploads / ActiveStorage ---
gem "image_processing", "~> 1.2" # manipulação de imagens

# --- Internacionalização ---
gem "rails-i18n", "~> 7.0"       # traduções oficiais

# --- Produção ---
group :production do
  gem "lograge", "~> 0.14"           # logs JSON estruturados
  gem "puma_worker_killer", "~> 0.3" # recicla workers com leak de memória
  gem "rack-attack", "~> 6.7"        # rate limiting (segurança)
  gem "rack-timeout", "~> 0.7"       # timeout em requests travados
  # gem "rails_12factor"              # necessário só em Heroku/Render (logs + assets)
  # gem "secure_headers"              # segurança extra (CSP/HSTS)
end

# --- Desenvolvimento & Teste ---
group :development, :test do
  gem "dotenv-rails", "~> 3.1"   # carrega variáveis de ambiente de .env
  gem "debug", "~> 1.11"         # debugger nativo Ruby
  gem "web-console", "~> 4.2"    # console no browser
  gem "listen", "~> 3.9"         # detecta mudanças nos arquivos
  gem "bindex", "~> 0.8"         # suporte para backtraces no IRB

  # Testes (boa prática)
  gem "rspec-rails", "~> 6.0"    # framework de testes
  gem "factory_bot_rails"        # factories de teste
  gem "faker"                    # geração de dados falsos
end

# --- Desenvolvimento (dependências específicas por SO) ---
group :development do
  gem "rb-fsevent", "~> 0.11"   # macOS file watcher (ignorado no Linux)
  gem "rb-inotify", "~> 0.11"   # Linux file watcher (ignorado no macOS)
end
