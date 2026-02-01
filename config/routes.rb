# frozen_string_literal: true

Rails.application.routes.draw do
  # =====================================================
  # 🔐 ADMINISTRAÇÃO DO SISTEMA
  # =====================================================
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # =====================================================
  # 🏠 HOME / LANDING INSTITUCIONAL
  # =====================================================
  root "pages#home"
  get "/inicio", to: "pages#home", as: :inicio

  # =====================================================
  # 🚛 LANDING PÚBLICA — TRANSPORTADORES
  # =====================================================
  # Página explicativa + qualificação
  # NÃO exige autenticação
  # =====================================================
  get "/transportadores", to: "transportadores/landing#index", as: :landing_transportadores

  # =====================================================
  # 🔐 AUTENTICAÇÃO — CLIENTES
  # =====================================================
  devise_for :clientes, controllers: {
    sessions:      "clientes/sessions",
    registrations: "clientes/registrations",
    passwords:     "clientes/passwords",
    confirmations: "clientes/confirmations"
  }

  # =====================================================
  # 🔐 AUTENTICAÇÃO — TRANSPORTADORES
  # =====================================================
  devise_for :transportadores, controllers: {
    sessions:      "transportadores/sessions",
    registrations: "transportadores/registrations",
    passwords:     "transportadores/passwords",
    confirmations: "transportadores/confirmations"
  }

  # =====================================================
  # 🏢 PÁGINAS INSTITUCIONAIS
  # =====================================================
  get "/sobre",   to: "pages#about",  as: :sobre
  get "/contato", to: "contatos#new", as: :contato

  # =====================================================
  # 🚚 SIMULAÇÃO DE FRETE (PÚBLICA)
  # =====================================================
  get  "/simular-frete", to: "fretes#new",     as: :simular_frete
  post "/simular-frete", to: "fretes#simular", as: :simular_frete_post

  # =====================================================
  # 👤 CLIENTES — ÁREA AUTENTICADA
  # =====================================================
  namespace :clientes do
    get "dashboard", to: "dashboards#index", as: :dashboard

    get  "completar_cadastro",  to: "cadastro#edit",   as: :completar_cadastro
    patch "finalizar_cadastro", to: "cadastro#update", as: :finalizar_cadastro
  end

  # =====================================================
  # 🚛 TRANSPORTADORES — ÁREA AUTENTICADA
  # =====================================================
  namespace :transportadores do
    get "dashboard", to: "dashboards#index", as: :dashboard

    get  "completar_perfil",  to: "cadastro#edit",   as: :completar_perfil
    patch "atualizar_perfil", to: "cadastro#update", as: :atualizar_perfil
  end

  # =====================================================
  # 📦 FRETES — CORE DO SISTEMA
  # =====================================================
  resources :fretes do
    member do
      get :chat
      get :rastreamento
    end
  end

  # =====================================================
  # 🚫 FALLBACK — 404 CONTROLADO
  # =====================================================
  match "*path", to: "errors#not_found", via: :all
end
