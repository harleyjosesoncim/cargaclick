# frozen_string_literal: true

Rails.application.routes.draw do
  # =====================================================
  # DASHBOARDS E ÁREAS RESTRITAS (Ajustado)
  # =====================================================
  namespace :clientes do
    root to: "dashboards#index" # Cria o clientes_root_path
  end

  namespace :transportadores do
    root to: "dashboards#index" # Cria o transportadores_root_path
  end

  # =====================================================
  # PÁGINA INICIAL
  # =====================================================
  root "home#index"

  # =====================================================
  # FRETES — NÚCLEO DO SISTEMA
  # =====================================================
  resources :fretes, except: [:index] do
    member do
      get :pagar
    end
  end

  # Redirecionamento seguro para evitar erro 500
  get "/fretes", to: redirect("/fretes/new")
  get "/simular-frete", to: "fretes#new", as: :simular_frete

  # =====================================================
  # PÁGINAS INSTITUCIONAIS
  # =====================================================
  scope controller: :home do
    get :about
    get :contato
    get :fidelidade
    get :relatorios
  end

  # =====================================================
  # CLIENTES E TRANSPORTADORES (CRUD)
  # =====================================================
  resources :clientes, except: [:new, :create] do
    collection do
      get  :new
      post :create
    end
  end

  get "/transportadores/cadastro", to: "transportadores#cadastro", as: :cadastro_transportador
  resources :transportadores, except: [:new, :create]

  # =====================================================
  # API E HEALTH
  # =====================================================
  namespace :api, defaults: { format: :json } do
    namespace :transportadores do
      post :optin
    end
  end

  get "/health", to: proc { [200, { "Content-Type" => "text/plain" }, ["OK"]] }
  get "/up",     to: redirect("/")

  # =====================================================
  # FALLBACK GLOBAL (Última rota sempre)
  # =====================================================
  match "*path", to: redirect("/"), via: :all, constraints: lambda { |req|
    req.path.exclude? 'rails/active_storage'
  }
end