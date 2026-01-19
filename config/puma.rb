# config/puma.rb
# frozen_string_literal: true
# Puma configuration for CargaClick (Dev / Prod / Render / Docker)

require "fileutils"

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
# Bind / Porta
# - Usa PORT (default 3000) OU PUMA_BIND, nunca os dois
# --------------------------------------------------
bind_url = ENV.fetch("PUMA_BIND", "").strip

if bind_url.empty?
  port Integer(ENV.fetch("PORT", 3000))
else
  if bind_url.start_with?("unix://")
    sock_path = bind_url.sub(/\Aunix:\/\//, "")
    FileUtils.mkdir_p(File.dirname(sock_path))
  end
  bind bind_url
end

# --------------------------------------------------
# Workers / Cluster
# - Dev: processo único
# - Prod: cluster com preload
# --------------------------------------------------
cluster_mode = false

if rails_env == "production"
  web_conc = Integer(ENV.fetch("WEB_CONCURRENCY", 2))
  workers web_conc
  preload_app! if web_conc > 0
  cluster_mode = web_conc > 0
else
  workers 0
end

# --------------------------------------------------
# Timeout
# --------------------------------------------------
worker_timeout Integer(
  ENV.fetch(
    "PUMA_WORKER_TIMEOUT",
    rails_env == "development" ? 3600 : 60
  )
)

# --------------------------------------------------
# Hooks de banco (somente em cluster)
# --------------------------------------------------
if cluster_mode && defined?(ActiveRecord::Base)
  before_fork do
    ActiveRecord::Base.connection_pool.disconnect!
  end

  on_worker_boot do
    ActiveRecord::Base.establish_connection
  end
end

# --------------------------------------------------
# Arquivos auxiliares
# --------------------------------------------------
FileUtils.mkdir_p("tmp/pids")
pidfile    ENV.fetch("PIDFILE", "tmp/pids/puma.pid")
state_path ENV.fetch("STATEFILE", "tmp/pids/puma.state")

plugin :tmp_restart

# --------------------------------------------------
# Tratamento de erro de baixo nível (500 silencioso)
# --------------------------------------------------
lowlevel_error_handler do |ex, _env|
  STDERR.puts "[puma][lowlevel_error] #{ex.class}: #{ex.message}"
  STDERR.puts ex.backtrace.first(5).join("\n") if ex.backtrace
  [500, { "Content-Type" => "text/plain" }, ["Internal Server Error\n"]]
end
