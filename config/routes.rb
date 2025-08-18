# frozen_string_literal: true

Rails.application.routes.draw do
  # Página inicial
  root "home#index"

  # Healthcheck e favicon (evita 404 barulhento nos logs)
  get "/up",          to: "rails/health#show", as: :health_check
  get "/favicon.ico", to: proc { [204, {}, []] }

  # Autenticação (Devise) — ajuste os controllers se forem outros
  devise_for :clientes,
             path: "clientes",
             controllers: {
               sessions:      "clientes/sessions",
               registrations: "clientes/registrations"
             }
             devise_for :clientes, path: "clientes"   # sem controllers custom, por enquanto
#

  # Recursos simples
  resources :clientes, only: [:index]

  # Fretes (somente o que você usa) + rotas membro usadas nas views
  resources :fretes, only: %i[index new create show] do
    member do
      get  :chat            # => chat_frete_path(:id)
      get  :rastreamento    # => rastreamento_frete_path(:id)
      post :gerar_proposta  # => gerar_proposta_frete_path(:id)
      post :entregar        # => entregar_frete_path(:id) (se usar)
    end
  end

  # Listagem pública e “bolsão”
  resources :transportadores, only: %i[index show]   # => transportadores_path
  get "/bolsao", to: "fretes#bolsao", as: :bolsao    # => bolsao_path

  # Admin (monta só se a gem estiver presente)
  mount RailsAdmin::Engine => "/rails_admin", as: "rails_admin" if defined?(RailsAdmin)
end

