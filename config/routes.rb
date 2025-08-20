# config/routes.rb
Rails.application.routes.draw do
  # Healthcheck (Rails 7)
  get "up", to: "rails/health#show", as: :rails_health_check

  # === AUTENTICAÇÃO (UMA ÚNICA DECLARAÇÃO) =====================
  devise_for :clientes,
             path: "clientes",
             controllers: {
               sessions:      "clientes/sessions",
               registrations: "clientes/registrations",
               passwords:     "clientes/passwords"
             }
  # =============================================================

  # Raiz autenticada vs pública
  authenticated :cliente do
    root "fretes#index", as: :authenticated_root
  end

  unauthenticated do
    root "home#index", as: :unauthenticated_root
  end

  # ATENÇÃO: deixe só index/show para não colidir com o Devise (POST /clientes)
  resources :clientes, only: [:index, :show]

  resources :transportadores, only: [:index]
  resources :fretes

  # Atalhos/aliases
  get "fretes/novo", to: "fretes#new",   as: :novo_frete
  get "bolsao",      to: "fretes#queue", as: :bolsao_solicitacoes
end
