# config/puma.rb — Puma para Rails 6/7 (Render/Docker)
require "fileutils"
require "etc"

FileUtils.mkdir_p("tmp/pids")
FileUtils.mkdir_p("tmp/sockets")

# ===== Ambiente =====
environment ENV.fetch("RAILS_ENV", "development")

# (Opcional) Tag para logs do Puma
tag ENV.fetch("PUMA_TAG", "cargaclick")

# ===== Threads =====
# Usa RAILS_MAX_THREADS (ou MAX_THREADS/PUMA_THREADS), mesmo valor para min/max.
threads_count = Integer(
  ENV.fetch("RAILS_MAX_THREADS",
    ENV.fetch("MAX_THREADS",
      ENV.fetch("PUMA_THREADS", "5")
    )
  )
)
threads threads_count, threads_count

# ===== Workers (cluster) =====
# Default: 2 workers se a máquina tiver >1 CPU, senão 1.
cpu             = (Etc.nprocessors rescue 2)
default_workers = cpu > 1 ? 2 : 1
workers_count   = Integer(ENV.fetch("WEB_CONCURRENCY", default_workers.to_s))
workers workers_count

# ===== Porta / Bind =====
# Render injeta PORT. Bind em 0.0.0.0 para aceitar tráfego do container.
port Integer(ENV.fetch("PORT", "3000")), "0.0.0.0"

# ===== Timeouts =====
# Em dev: 60s para evitar queda durante debug; em prod pode ser menor.
if ENV.fetch("RAILS_ENV", "development") == "development"
  worker_timeout 60
else
  worker_timeout Integer(ENV.fetch("PUMA_WORKER_TIMEOUT", "30"))
end

# ===== Preload & Hooks de banco =====
preload_app!  # economiza RAM (copy-on-write) e acelera fork

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

# ===== PIDs/State =====
pidfile    ENV.fetch("PUMA_PIDFILE", "tmp/pids/puma.pid")
state_path ENV.fetch("PUMA_STATEFILE", "tmp/pids/puma.state")

# ===== Rackup explícito =====
rackup "config.ru"

# ===== Low-level error handler (loga exceções fora do Rails) =====
lowlevel_error_handler do |ex, _env|
  $stderr.puts "Puma lowlevel_error: #{ex.class}: #{ex.message}\n#{ex.backtrace&.first(5)&.join("\n")}"
  [500, { "Content-Type" => "text/plain" }, ["Internal Server Error"]]
end

# ===== Dev convenience =====
plugin :tmp_restart  # permite `bin/rails restart` em dev
