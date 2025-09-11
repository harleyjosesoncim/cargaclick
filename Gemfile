# frozen_string_literal: true

source "https://rubygems.org"

ruby "3.2.4"

# === Núcleo do Rails =========================================================
gem "rails", "~> 7.1.5", ">= 7.1.5.1"
gem "pg", ">= 1.5", "< 2.0"                 # PostgreSQL
gem "puma", "~> 6.6"                        # Servidor web
gem "bootsnap", ">= 1.17", require: false   # Cache para acelerar boot da app
gem "json", ">= 2.6"

# Admin
gem "activeadmin"

# === Autenticação ============================================================
gem "devise", "~> 4.9"                      # Clientes, Transportadores e Admins

# === Integração Mercado Pago (SDK oficial) ==================================
gem "mercadopago-sdk", "~> 2.3", require: "mercadopago"

# === Frontend / Hotwire + Tailwind ==========================================
gem "turbo-rails", "~> 2.0"
gem "tailwindcss-rails", "~> 4.1"
gem "sprockets-rails", "~> 3.4"             # Suporte a assets legado
gem "sassc-rails", "~> 2.1"                 # Compilação SCSS
gem "uglifier", ">= 4.2"                    # Minificação JS legado
gem "sitemap_generator"

# === Uploads / ActiveStorage ================================================
gem "image_processing", "~> 1.2"

# === Internacionalização ====================================================
gem "rails-i18n", "~> 7.0"

# === Segurança ==============================================================
gem "secure_headers", "~> 6.5"              # Cabeçalhos de segurança

# === Produção ===============================================================
group :production do
  gem "lograge", "~> 0.14"                  # Logs mais limpos
  gem "puma_worker_killer", "~> 0.3"        # Protege contra memory leaks
  gem "rack-attack", "~> 6.7"               # Rate limiting / segurança
  gem "rack-timeout", "~> 0.7"              # Timeout de requisições
end

# === Desenvolvimento & Teste ================================================
group :development, :test do
  gem "dotenv-rails", "~> 3.1"              # Carrega variáveis do .env
  gem "debug", "~> 1.11"                    # Debugger
  gem "web-console", "~> 4.2"               # Console via navegador
  gem "listen", "~> 3.9"                    # Reload automático
  gem "bindex", "~> 0.8"                    # Suporte ao debugger

  # Testes
  gem "rspec-rails", "~> 6.0"               # Framework de testes
  gem "factory_bot_rails"                   # Factories
  gem "faker"                               # Dados fake
  gem "capybara"                            # Testes de integração
  gem "selenium-webdriver"                  # Navegador para testes
end

# === Desenvolvimento específico de SO ======================================
group :development do
  gem "rb-fsevent", "~> 0.11", require: false # macOS
  gem "rb-inotify", "~> 0.11", require: false # Linux
end
