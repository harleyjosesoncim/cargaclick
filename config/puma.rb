# Threads e workers básicos
threads_count = Integer(ENV.fetch("RAILS_MAX_THREADS", 5))
threads threads_count, threads_count
workers Integer(ENV.fetch("WEB_CONCURRENCY", 2))

preload_app!

# Render define PORT; dê fallback para 3000 local
port ENV.fetch("PORT", 3000)
bind "tcp://0.0.0.0:#{ENV.fetch('PORT', 3000)}"

environment ENV.fetch("RACK_ENV", "production")

plugin :tmp_restart
