# config/routes.rb
Rails.application.routes.draw do
  # Healthcheck (Render/uptime)
  get "up", to: "rails/health#show", as: :rails_health_check

  # Home
  root "home#index"

  # Devise (Clientes)
  devise_for :clientes,
             path: "clientes",
             controllers: {
               sessions:      "clientes/sessions",
               registrations: "clientes/registrations",
               passwords:     "clientes/passwords"
             }

  # Domínio de negócio
  resources :fretes
  get "fretes/novo", to: "fretes#new",   as: :novo_frete
  get "bolsao",      to: "fretes#queue", as: :bolsao_solicitacoes

  # Listagens (botões da Home)
  resources :clientes,        only: [:index]        # GET /clientes  -> ClientesController#index
  resources :transportadores, only: [:index]        # GET /transportadores -> TransportadoresController#index

  # 404 custom (opcional; deixe comentado até ter ErrorsController)
  # get "*unmatched", to: "errors#not_found", via: :all
end
