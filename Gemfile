# Gemfile
source "https://rubygems.org"
ruby "3.2.4"

# Detecta o SO para gems específicas em dev
require "rbconfig"
HOST_OS = RbConfig::CONFIG["host_os"]

# --- Núcleo (produção também usa)
gem "rails", "~> 7.1"
gem "pg", ">= 1.5", "< 2.0"
gem "bootsnap", ">= 1.17", require: false

# --- Assets (Sprockets + SassC). Se você migrar p/ Propshaft, ajuste aqui.
gem "sprockets-rails", "~> 3.4"
gem "sassc-rails", "~> 2.1"

# --- Autenticação
gem "devise"

# --- Produção: observabilidade e proteção
group :production do
  gem "lograge", "~> 0.14"           # logs mais limpos
  gem "puma_worker_killer", "~> 0.3" # recicla workers por memória
  gem "rack-attack", "~> 6.7"        # rate limiting / proteção
  gem "puma", "~> 6.6" # servidor web
  gem "rack-timeout", "~> 0.7"       # timeout em requests travados
end

# --- Desenvolvimento e Teste
group :development, :test do
  gem "dotenv-rails", "~> 3.1"  # sem require: rails-now (deprecado)
  gem "debug", "~> 1.11"
  gem "web-console", "~> 4.2"
  gem "listen", "~> 3.9"
  gem "bindex", "~> 0.8"
end

# --- Desenvolvimento: watchers por plataforma
group :development do
  gem "rb-fsevent", "~> 0.11" if HOST_OS =~ /darwin/i # macOS
  gem "rb-inotify", "~> 0.11" if HOST_OS =~ /linux/i  # Linux/WSL
end
