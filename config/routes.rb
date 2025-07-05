Rails.application.routes.draw do
  root 'home#index'

  resources :clientes
  resources :transportadores
  resources :fretes
  resources :pagamento, only: [:show]


  # Pode adicionar rotas como login, dashboard, etc.
end
