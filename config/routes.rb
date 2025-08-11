cd ~/projects/Cargaclick

# sobrescreve config/routes.rb com a versão final
cat > config/routes.rb <<'RUBY'
# frozen_string_literal: true

Rails.application.routes.draw do
  # Health check
  get "up", to: "rails/health#show", as: :rails_health_check

  # Canonical: cargaclick.com.br -> www.cargaclick.com.br
  constraints(host: "cargaclick.com.br") do
    get "/" => redirect("https://www.cargaclick.com.br/")
    match "(*path)", to: redirect { |params, req|
      qs = req.query_string.to_s
      "https://www.cargaclick.com.br/#{params[:path]}#{qs.empty? ? "" : "?#{qs}"}"
    }, via: :all
  end

  # Página inicial
  root "home#index"

  # Devise
  devise_for :clientes, controllers: {
    registrations: "clientes/registrations",
    sessions: "clientes/sessions",
    passwords: "clientes/passwords"
  }
  devise_for :transportadores, controllers: {
    registrations: "transportadores/registrations",
    sessions: "transportadores/sessions",
    passwords: "transportadores/passwords"
  }

  # Propostas
  resources :propostas do
    member { get :gerar_proposta_inteligente }
  end

  # Modals
  resources :modals

  # Fretes
  resources :fretes do
    member do
      get  :rastreamento
      post :entregar
      get  :chat
    end
    collection { get :meus }
  end

  # Clientes
  resources :clientes do
    member { get "fidelidade", to: "fidelidade#cliente", as: "fidelidade" }
  end

  # Transportadores
  resources :transportadores do
    member { get "fidelidade", to: "fidelidade#transportador", as: "fidelidade" }
  end

  # Admin
  get "admin/dashboard", to: "admin/dashboard#index"
  namespace :admin do
    get   "/",      to: "dashboard#index",  as: "index"
    patch "update", to: "dashboard#update", as: "update"
  end

  # Bolsão & Ranking
  get "bolsao",  to: "bolsao#index",  as: "bolsao"
  get "ranking", to: "ranking#index", as: "ranking"

  #
