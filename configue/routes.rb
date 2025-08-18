# frozen_string_literal: true

Rails.application.routes.draw do
  # Página inicial
  root "home#index"

  # Healthcheck e favicon (evita 404 nos logs)
  get "/up", to: "rails/health#show", as: :health_check
  get "/favicon.ico", to: proc { [204, {}, []] }

  # Autenticação com Devise
  devise_for :clientes,
             path: "clientes",
             controllers: {
               sessions: "clientes/sessions",
               registrations: "clientes/registrations"
             }

  # Recursos simples
  resources :clientes, only: [:index]

  # Fretes com rotas personalizadas
  resources :fretes, only: %i[index new create show] do
    member do
      get :chat             # => /fretes/:id/chat
      get :rastreamento     # => /fretes/:id/rastreamento
      post :gerar_proposta  # => /fretes/:id/gerar_proposta
      post :entregar        # => /fretes/:id/entregar
    end
  end

  # Listagem pública e "bolsão"
  resources :transportadores, only: %i[index show]  # => /transportadores, /transportadores/:id
  get "/bolsao", to: "fretes#bolsao", as: :bolsao   # => /bolsao

  # Admin (montado apenas se a gem rails_admin estiver presente)
  mount RailsAdmin::Engine => "/rails_admin", as: "rails_admin" if defined?(RailsAdmin)
end