# Gemfile
source "https://rubygems.org"
ruby "3.2.4"

# Detecta o sistema operacional (para gems de file-watcher)
require "rbconfig"
HOST_OS = RbConfig::CONFIG["host_os"]

# --- Núcleo
gem "rails", "~> 7.1"
gem "pg", ">= 1.5", "< 2.0"
gem "puma", "~> 6.6"
gem "bootsnap", ">= 1.17", require: false

# --- Assets (Sprockets + Sass). Se usar Propshaft, remova estes e adicione `propshaft`.
gem "sprockets-rails"
gem "sassc-rails"

# --- Hotwire (se usar)
gem "turbo-rails"
gem "stimulus-rails"

# --- Autenticação
gem "devise"
gem "responders"

# --- Cache / Rate limit
gem "redis", "~> 5.0"        # opcional, recomendado p/ sessão/cache
gem "rack-attack"            # proteção básica

# --- Produção
group :production do
  gem "lograge", "~> 0.14"           # logs concisos
  gem "rack-timeout", "~> 0.6"       # mata requests travadas
  gem "puma_worker_killer", "~> 0.3" # recicla workers por memória
  # gem "sentry-ruby"                # opcional
end

# --- Windows (dev em Windows)
gem "tzinfo-data", platforms: %i[mingw mswin x64_mingw jruby]

# --- Dev & Test (NÃO vai para produção)
group :development, :test do
  gem "dotenv-rails"                  # carrega .env local
  gem "debug", ">= 1.11.0", platforms: %i[mri mingw x64_mingw]
end

group :development do
  gem "web-console"
  gem "listen", "~> 3.9"
  gem "spring"
  gem "spring-watcher-listen", "~> 2.1"
  gem "bindex"

  # Watchers específicos por SO — sem usar `platforms: :darwin`
  if HOST_OS =~ /darwin/i
    gem "rb-fsevent", require: false
  elsif HOST_OS =~ /linux/i
    gem "rb-inotify", require: false
  end
end

