Rails.application.routes.draw do
  # Página inicial
  root 'home#index'

  # Clientes
  resources :clientes

  # Transportadores
  resources :transportadores

  # Fretes
  resources :fretes do
    collection do
      get 'calcular' # Para a simulação de frete
    end
    member do
      get 'rastreamento', to: 'fretes#rastreamento'
    end
  end

  # Bolsão de Solicitações
  get '/bolsao', to: 'bolsao#index', as: 'bolsao'

  # Propostas (rotas REST corretas)
  get '/propostas/nova', to: 'propostas#nova', as: 'nova_proposta'
  post '/propostas', to: 'propostas#create', as: 'propostas'

  # Se quiser um mapa geral (todas cargas, visão admin), crie um controller separado:
  # get '/mapa', to: 'rastreamento#mapa'

  # Outras rotas
end
