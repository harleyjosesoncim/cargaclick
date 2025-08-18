# config/routes.rb
Rails.application.routes.draw do
  # Healthcheck
  get "up", to: "rails/health#show", as: :rails_health_check

  # DEBUG: rota de fumaça (ignora controller e banco)
get "/clientes", to: proc { [200, {"Content-Type"=>"text/plain"}, ["ok /clientes (rack)"]] }

  # Home
  root "home#index"

  # Devise (Clientes)
  devise_for :clientes,
             path: "clientes",
             controllers: {
               sessions: "clientes/sessions",
               registrations: "clientes/registrations",
               passwords: "clientes/passwords"
             }

  # Negócio
  resources :fretes
  get "fretes/novo", to: "fretes#new", as: :novo_frete       # atalho opcional
  get "bolsao", to: "fretes#queue", as: :bolsao_solicitacoes # Bolsão de Solicitações

  # Páginas de listagem/landing (GET) — usadas pelos botões da Home
  resources :clientes, only: [:index]
  resources :transportadores, only: [:index]

  # Opcional: áreas autenticadas
  # authenticate :cliente do
  #   get "dashboard", to: "dashboard#show", as: :cliente_dashboard
  # end

  # Opcional: 404 custom
  # get "*unmatched", to: "errors#not_found", via: :all
end
