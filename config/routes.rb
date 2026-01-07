# frozen_string_literal: true

Rails.application.routes.draw do
  root "home#index"

  # =====================================================
  # FRETES — NÚCLEO DO SISTEMA
  # =====================================================
  # Definimos o resources primeiro, mas EXCLUÍMOS o index 
  # para que ele não tente renderizar a view deletada.
  resources :fretes, except: [:index] do
    member do
      get :pagar
    end
  end

  # Agora forçamos o redirecionamento do index para o new de forma segura
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
  # CLIENTES E TRANSPORTADORES
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
  # FALLBACK GLOBAL
  # =====================================================
  # Coloque sempre como a ÚLTIMA rota do arquivo
  match "*path", to: redirect("/"), via: :all, constraints: lambda { |req|
    req.path.exclude? 'rails/active_storage' # Evita quebrar uploads
  }
end