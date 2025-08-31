# config/puma.rb
# Puma configuration for CargaClick (Render/Docker ready)

# Número de threads por worker (mínimo e máximo iguais)
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

# Porta definida pelo Render (ou 3000 em dev)
port ENV.fetch("PORT") { 3000 }

# Não precisa de bind manual: Render já seta PORT corretamente
# bind "tcp://0.0.0.0:#{ENV.fetch("PORT") { 3000 }}"

# Ambiente padrão: production em Render, development local
environment ENV.fetch("RAILS_ENV") { "development" }

# Workers (processos paralelos). 0 => single mode
workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# Preload melhora uso de memória em produção
preload_app!

# Reconexão do ActiveRecord após fork
on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

# Suporte a `rails restart`
plugin :tmp_restart
