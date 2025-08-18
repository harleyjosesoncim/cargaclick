# config/puma.rb — Puma para Rails 6/7

require "fileutils"
FileUtils.mkdir_p("tmp/pids")
FileUtils.mkdir_p("tmp/sockets")

# Threads
threads_count = Integer(ENV.fetch("RAILS_MAX_THREADS", ENV.fetch("PUMA_THREADS", 5)))
threads threads_count, threads_count

# Ambiente
environment ENV.fetch("RAILS_ENV", "development")

# Porta (Render/Heroku define PORT; local usa 3000)
port ENV.fetch("PORT", 3000)

# PIDs/State
pidfile "tmp/pids/puma.pid"
state_path "tmp/pids/puma.state"

# Timeout em dev
worker_timeout 60 if ENV.fetch("RAILS_ENV", "development") == "development"

# Workers (cluster) — defina WEB_CONCURRENCY (ex.: 2) para ativar
workers_count = Integer(ENV.fetch("WEB_CONCURRENCY", 0))
workers workers_count if workers_count > 0

# Preload quando em cluster
preload_app! if workers_count > 0

# Hooks de ActiveRecord apenas em cluster
if workers_count > 0
  before_fork do
    if defined?(ActiveRecord::Base)
      ActiveRecord::Base.connection_pool.disconnect!
    end
  end

  on_worker_boot do
    if defined?(ActiveRecord::Base)
      ActiveRecord::Base.establish_connection
    end
  end
end

# Permite `bin/rails restart` em dev
plugin :tmp_restart

# Rackup explícito
rackup "config.ru"
