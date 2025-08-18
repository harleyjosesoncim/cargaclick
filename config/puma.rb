# frozen_string_literal: true

# Threads
max_threads = Integer(ENV.fetch("RAILS_MAX_THREADS", 5))
min_threads = Integer(ENV.fetch("RAILS_MIN_THREADS", max_threads))
threads min_threads, max_threads

# Ambiente
environment ENV.fetch("RAILS_ENV", "production")

# Bind explícito (Render usa PORT=10000; no compose vamos mapear 3000 -> 10000)
bind "tcp://0.0.0.0:#{ENV.fetch('PORT', '10000')}"

# Concurrency (0 = single)
workers Integer(ENV.fetch("WEB_CONCURRENCY", 0))
preload_app!

# PID e restart
pidfile ENV.fetch("PIDFILE", "tmp/pids/server.pid")
plugin :tmp_restart

