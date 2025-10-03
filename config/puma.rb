# config/puma.rb
# Puma configuration for CargaClick (Render/Docker ready)

require "fileutils"
FileUtils.mkdir_p("tmp/pids")

# -----------------------------
# Threads
# -----------------------------
max_threads = Integer(ENV.fetch("RAILS_MAX_THREADS", 5))
min_threads = Integer(ENV.fetch("RAILS_MIN_THREADS", max_threads))
threads min_threads, max_threads

# -----------------------------
# Porta / Ambiente
# -----------------------------
port        Integer(ENV.fetch("PORT", 3000))
environment ENV.fetch("RAILS_ENV", ENV.fetch("RACK_ENV", "production"))

# -----------------------------
# Workers (processos)
# Em produção use 2+ se a máquina tiver CPU/memória.
# Em dev/local, pode usar 0 (modo single process).
# -----------------------------
workers Integer(ENV.fetch("WEB_CONCURRENCY", 2))

# Evita reinícios por request lento em dev (útil no WSL)
worker_timeout Integer(ENV.fetch("PUMA_WORKER_TIMEOUT", (ENV["RAILS_ENV"] == "development" ? 3600 : 60)))

# -----------------------------
# Preload e DB reconnection
# -----------------------------
preload_app!

before_fork do
  # Desconecta conexões antes do fork
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.connection_pool.disconnect!
  end
end

on_worker_boot do
  # Reestabelece conexão por worker
  if defined?(ActiveRecord::Base)
    ActiveRecord::Base.establish_connection
  end
end

# -----------------------------
# PID/State (facilita parar com pumactl)
# -----------------------------
pidfile    ENV.fetch("PIDFILE", "tmp/pids/puma.pid")
state_path ENV.fetch("STATEFILE", "tmp/pids/puma.state")

# -----------------------------
# Bind opcional (se preferir usar UNIX socket)
# Ex.: export PUMA_BIND="unix://tmp/sockets/puma.sock"
# -----------------------------
if ENV["PUMA_BIND"].to_s.strip != ""
  bind ENV["PUMA_BIND"]
end

# Permite `bin/rails restart`
plugin :tmp_restart

