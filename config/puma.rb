# Puma configuration for CargaClick (Render/Docker ready)

# Número de threads por worker (mínimo e máximo iguais)
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

# Porta que o Render define via ENV
port ENV.fetch("PORT") { 3000 }

# Bind para todas as interfaces (necessário em container)
bind "tcp://0.0.0.0:#{ENV.fetch("PORT") { 3000 }}"

# Define o ambiente
environment ENV.fetch("RAILS_ENV") { "production" }

# Workers (processos em paralelo). 
# Se WEB_CONCURRENCY não for definido, roda em modo single-process.
workers ENV.fetch("WEB_CONCURRENCY") { 0 }.to_i

# Preload melhora uso de memória em produção
preload_app!

# Reconexão do ActiveRecord após fork
on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

# Suporte a `rails restart`
plugin :tmp_restart
