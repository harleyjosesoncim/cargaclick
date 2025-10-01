# config/puma.rb
# Puma configuration for CargaClick (Render/Docker ready)

# Threads (mínimo e máximo iguais por simplicidade)
threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
threads threads_count, threads_count

# Porta definida pelo Render (ou 3000 local)
port ENV.fetch("PORT") { 3000 }

# Ambiente padrão
environment ENV.fetch("RAILS_ENV") { "production" }

# Workers (processos paralelos)
workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# Preload melhora uso de memória em produção
preload_app!

# Reconexão de DB após fork (necessário no Render)
on_worker_boot do
  ActiveRecord::Base.connection_pool.disconnect! rescue ActiveRecord::ConnectionNotEstablished
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

# Permite `rails restart`
plugin :tmp_restart
