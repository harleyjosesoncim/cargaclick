port ENV.fetch("PORT") { 3000 }
bind "tcp://0.0.0.0:#{ENV.fetch("PORT") { 3000 }}"
workers Integer(ENV.fetch("WEB_CONCURRENCY", 0))
preload_app!
