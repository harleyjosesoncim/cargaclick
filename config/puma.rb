# config/puma.rb
# frozen_string_literal: true

max_threads = ENV.fetch("RAILS_MAX_THREADS", 5).to_i
min_threads = ENV.fetch("RAILS_MIN_THREADS", max_threads).to_i
threads min_threads, max_threads

environment ENV.fetch("RAILS_ENV", "development")

# Render define ENV["PORT"] (ex.: 10000). Use essa porta e 0.0.0.0
port ENV.fetch("PORT", 3000)
# Se preferir, pode forçar explicitamente o bind (equivalente ao 'port' acima):
# bind "tcp://0.0.0.0:#{ENV.fetch('PORT', 3000)}"

pidfile ENV.fetch("PIDFILE", "tmp/pids/server.pid")

workers ENV.fetch("WEB_CONCURRENCY", 0).to_i
preload_app! if ENV["WEB_CONCURRENCY"].to_i > 0

plugin :tmp_restart

