# Gemfile
source "https://rubygems.org"
ruby "3.2.4"

# Detecta o sistema operacional para gemas específicas
require "rbconfig"
HOST_OS = RbConfig::CONFIG["host_os"]

# --- Núcleo (gemas de produção)
gem "rails", "~> 7.1"
gem "pg", ">= 1.5", "< 2.0"
gem "puma", "~> 6.6"
gem "bootsnap", ">= 1.17", require: false
gem "sprockets-rails", "~> 3.4"
gem "sassc-rails", "~> 2.1" # para compilar arquivos .scss
gem "devise" # ✅ Autenticação sempre carregada (inclusive em produção)

# --- Produção: Gemas adicionais recomendadas
gem "lograge", "~> 0.14"              # Logs estruturados para produção
gem "puma_worker_killer", "~> 0.3"    # Gerenciamento de memória do Puma
gem "rack-attack", "~> 6.7"           # Proteção contra abusos (rate limiting)
gem "rack-timeout", "~> 0.7"          # Tempo limite para requisições

# --- Desenvolvimento e Teste
group :development, :test do
  gem "dotenv-rails", "~> 3.1", require: "dotenv/rails-now" # Carrega variáveis de ambiente cedo
  gem "debug", "~> 1.11"
  gem "web-console", "~> 4.2"
  gem "listen", "~> 3.9"
  gem "bindex", "~> 0.8" # Binding para web-console
end

# --- Desenvolvimento: Gemas específicas por plataforma
group :development do
  gem "rb-fsevent", "~> 0.11" if HOST_OS =~ /darwin/i # macOS
  gem "rb-inotify", "~> 0.11" if HOST_OS =~ /linux/i  # Linux (inclui WSL)
end
