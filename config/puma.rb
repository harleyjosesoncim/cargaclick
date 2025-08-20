# config/puma.rb
# frozen_string_literal: true

require "fileutils"
FileUtils.mkdir_p("tmp/pids")

env = ENV.fetch("RAILS_ENV", "development")

# Tag opcional para logs
tag ENV.fetch("PUMA_TAG", "cargaclick")

# Threads (min/max)
min_threads = Integer(ENV.fetch("RAILS_MIN_THREADS", ENV.fetch("MIN_THREADS", 5)))
max_threads = Integer(ENV.fetch("RAILS_MAX_THREADS", ENV.fetch("MAX_THREADS", min_threads)))
threads min_threads, max_threads

# Porta/Bind (Render injeta PORT; local usa 3000)
bind "tcp://0.0.0.0:#{ENV.fetch('PORT', env == 'production' ? 10000 : 3000)}"
environment env

# Arquivos de estado
pidfile    ENV.fetch("PUMA_PIDFILE", "tmp/pids/server.pid")
state_path ENV.fetch("PUMA_STATEFILE", "tmp/pids/puma.state")

# Workers/cluster
if env == "production"
  workers Integer(ENV.fetch("WEB_CONCURRENCY", 2))
  preload_app!
  worker_timeout Integer(ENV.fetch("PUMA_WORKER_TIMEOUT", 30))
else
  workers 0              # sempre single-process em dev (hot reload estável)
  worker_timeout 60      # debug mais confortável
end

# DB hooks
before_fork   { ActiveRecord::Base.connection_pool.disconnect! if defined?(ActiveRecord::Base) }
on_worker_boot { ActiveRecord::Base.establish_connection         if defined?(ActiveRecord::Base) }

# Handler para erros fora do Rails
lowlevel_error_handler do |ex, _env|
  $stderr.puts "[puma] lowlevel_error #{ex.class}: #{ex.message}"
  [500, { "Content-Type" => "text/plain" }, ["Internal Server Error"]]
end

# Conveniência em dev: `bin/rails restart`
plugin :tmp_restart
