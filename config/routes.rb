# frozen_string_literal: true

Rails.application.routes.draw do
  # =====================================================
  # ADMIN (ActiveAdmin)
  # =====================================================
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # =====================================================
  # AUTH — CLIENTES (Devise)
  # =====================================================
  devise_for :clientes, controllers: {
    sessions:      "clientes/sessions",
    registrations: "clientes/registrations",
    passwords:     "clientes/passwords",
    confirmations: "clientes/confirmations"
  }

  # =====================================================
  # AUTH — TRANSPORTADORES (Devise)
  # =====================================================
  devise_for :transportadores, controllers: {
    sessions:      "transportadores/sessions",
    registrations: "transportadores/registrations",
    passwords:     "transportadores/passwords",
    confirmations: "transportadores/confirmations"
  }

  # =====================================================
  # LANDING / HOME
  # =====================================================
  root "landing#index"
  get "/inicio", to: "landing#index", as: :inicio

  # =====================================================
  # PÁGINAS PÚBLICAS
  # =====================================================
  get "/sobre",   to: "pages#about",  as: :sobre
  get "/contato", to: "contatos#new", as: :contato

  # =====================================================
  # SIMULAÇÃO DE FRETE (PÚBLICA)
  # =====================================================
  get "/simular-frete", to: "fretes#new", as: :simular_frete

  # =====================================================
  # CLIENTES — DASHBOARD E CADASTRO PROGRESSIVO
  # =====================================================
  namespace :clientes do
    # Dashboard
    get "dashboard", to: "dashboards#index", as: :dashboard

    # Completar cadastro (STEP 4)
    get  "completar_cadastro", to: "cadastro#edit",   as: :completar_cadastro
    patch "finalizar_cadastro", to: "cadastro#update", as: :finalizar_cadastro
  end

  # =====================================================
  # TRANSPORTADORES — DASHBOARD E PERFIL
  # =====================================================
  namespace :transportadores do
    # Dashboard
    get "dashboard", to: "dashboards#index", as: :dashboard

    # Completar perfil (fluxo futuro)
    get  "completar_perfil",  to: "cadastro#edit",   as: :completar_perfil
    patch "atualizar_perfil", to: "cadastro#update", as: :atualizar_perfil
  end

  # =====================================================
  # FRETES (CORE DO SISTEMA)
  # =====================================================
  resources :fretes do
    member do
      get :chat
      get :rastreamento
    end
  end

  # =====================================================
  # FALLBACK — 404 CONTROLADO
  # =====================================================
  match "*path", to: "errors#not_found", via: :all
end
