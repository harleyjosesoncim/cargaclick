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
  # LANDING / HOME (ÚNICO ROOT GLOBAL)
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
  # DASHBOARDS (ROTAS EXPLÍCITAS)
  # =====================================================
  get "/cliente/dashboard",
      to: "clientes/dashboards#index",
      as: :cliente_dashboard

  get "/transportador/dashboard",
      to: "transportadores/dashboards#index",
      as: :transportador_dashboard

  # =====================================================
  # TRANSPORTADOR — COMPLETAR PERFIL
  # =====================================================
  get "/transportadores/completar_perfil",
      to: "transportadores#completar_perfil",
      as: :completar_perfil_transportador

  patch "/transportadores/atualizar_perfil",
        to: "transportadores#atualizar_perfil",
        as: :atualizar_perfil_transportador

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
  # FALLBACK — 404 CONTROLADO (SEM QUEBRAR PRODUÇÃO)
  # =====================================================
  match "*path", to: "errors#not_found", via: :all
end
