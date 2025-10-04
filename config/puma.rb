# config/puma.rb
# frozen_string_literal: true
# Puma configuration for CargaClick (Dev ↔ Prod / Render / Docker)

require "fileutils"
FileUtils.mkdir_p("tmp/pids")

# --------------------------------------------------
# Ambiente
# --------------------------------------------------
rails_env = ENV.fetch("RAILS_ENV") { ENV.fetch("RACK_ENV", "development") }
environment rails_env
tag "cargaclick-#{rails_env}"

# --------------------------------------------------
# Threads
# --------------------------------------------------
max_threads = Integer(ENV.fetch("RAILS_MAX_THREADS", 5))
min_threads = Integer(ENV.fetch("RAILS_MIN_THREADS", max_threads))
threads min_threads, max_threads

# --------------------------------------------------
# Porta / Bind
# - Usa `port` por padrão. Se PUMA_BIND estiver definido, usa `bind`.
#   Ex.: PUMA_BIND=tcp://0.0.0.0:3000  ou  unix://tmp/sockets/puma.sock
# --------------------------------------------------
port Integer(ENV.fetch("PORT", 3000))
bind_url = ENV.fetch("PUMA_BIND", "").strip
unless bind_url.empty?
  if bind_url.start_with?("unix://")
    sock_path = bind_url.sub(/\Aunix:\/\//, "")
    FileUtils.mkdir_p(File.dirname(sock_path))
  end
  bind bind_url
end

# --------------------------------------------------
# Workers / Cluster
# - Dev: processo único (0) → evita EADDRINUSE e warnings de hooks
# - Prod: cluster com preload; WEB_CONCURRENCY padrão 2
# --------------------------------------------------
if rails_env == "production"
  web_conc = Integer(ENV.fetch("WEB_CONCURRENCY", 2))
  workers web_conc
  preload_app! if web_conc > 0
  cluster_mode = web_conc > 0
else
  workers 0
  cluster_mode = false
end

# Timeout (dev mais alto por conta de WSL; prod baixo)
worker_timeout Integer(
  ENV.fetch("PUMA_WORKER_TIMEOUT", rails_env == "development" ? 3600 : 60)
)

# --------------------------------------------------
# Hooks de banco (somente quando em cluster)
# --------------------------------------------------
if cluster_mode
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

# --------------------------------------------------
# Arquivos auxiliares (pumactl/diagnóstico)
# --------------------------------------------------
pidfile    ENV.fetch("PIDFILE", "tmp/pids/puma.pid")
state_path ENV.fetch("STATEFILE", "tmp/pids/puma.state")

# Permite `bin/rails restart`
plugin :tmp_restart

# Tratamento de erro de baixo nível (melhora logs de 500 inesperados)
lowlevel_error_handler do |ex, _env|
  STDERR.puts "[puma][lowlevel_error] #{ex.class}: #{ex.message}\n#{ex.backtrace&.first(5)&.join("\n")}"
  [500, { "Content-Type" => "text/plain" }, ["Internal Server Error\n"]]
end

