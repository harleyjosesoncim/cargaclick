Rails.application.routes.draw do
  resources :cotacaos
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
      # Cada frete pode ser rastreado individualmente, exemplo: /fretes/1/rastreamento
    end
  end

  # Se quiser um mapa geral (todas cargas, visão admin), crie um controller separado:
  # get '/mapa', to: 'rastreamento#mapa'

  # Outras rotas
end

