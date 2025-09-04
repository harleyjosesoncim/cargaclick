# frozen_string_literal: true

Rails.application.routes.draw do
  # === AUTENTICAÇÃO (Devise) ===================================
  devise_for :transportadores
  devise_for :admin_users

  devise_for :clientes,
             path: "clientes",
             controllers: {
               sessions:      "clientes/sessions",
               registrations: "clientes/registrations",
               passwords:     "clientes/passwords"
             }

  # === HEALTHCHECK ==============================================
  get "up", to: "rails/health#show", as: :rails_health_check

  # === PÁGINAS PÚBLICAS =========================================
  get "home",       to: "home#index"
  get "sobre",      to: "home#about",      as: :about
  get "contato",    to: "home#contact",    as: :contact
  get "fidelidade", to: "home#fidelidade", as: :fidelidade
  get "relatorios", to: "home#relatorios", as: :relatorios

  # === ROOTS ====================================================
  authenticated :cliente do
    root "fretes#index", as: :authenticated_root
  end

  unauthenticated do
    root "home#index", as: :unauthenticated_root
  end

  # 🔑 Root global (fallback)
  root "home#index"

  # === CLIENTES & TRANSPORTADORES ===============================
  resources :clientes do
    resources :fretes, only: [:index] # cliente pode ver seus fretes
  end

  resources :transportadores do
    member do
      get :fidelidade # pontos acumulados
    end
    resources :cotacoes, only: [:index] # transportador vê cotações
  end

  # === FRETES & COTAÇÕES ========================================
  resources :fretes do
    resources :cotacoes, only: [:index, :new, :create]

    member do
      get :pagar   # /fretes/:id/pagar
      get :status  # /fretes/:id/status
    end

    # 🔹 CHAT dentro de um frete (cliente x transportador)
    resources :messages, only: [:index, :create]
  end

  resources :cotacoes, only: [:index, :show, :edit, :update, :destroy] do
    member do
      post :aceitar
      post :recusar
    end
  end

  # === PROPOSTAS ================================================
  resources :propostas do
    member do
      get :gerar_proposta_inteligente
      get :bolsa # se tiver campo bolsa nas propostas
    end
  end

  # === OUTROS MÓDULOS ===========================================
  resources :modals
  resources :veiculos
  resources :cargas
  resources :tipos_cargas
  resources :unidades_medidas

  # === ATALHOS / ALIASES ========================================
  get "fretes/novo",      to: "fretes#new",   as: :novo_frete
  get "bolsao",           to: "fretes#queue", as: :bolsao_solicitacoes
  get "calcular_fretes",  to: "fretes#new",   as: :calcular_fretes

  # === PAGAMENTOS (Mercado Pago) ================================
  resources :pagamentos, only: [:create] do
    collection do
      get :sucesso
      get :falha
      get :pendente
    end
  end

  # === PAINEL ADMIN =============================================
  namespace :admin do
    root to: "dashboard#index"   # cria admin_root_path
    resources :clientes
    resources :transportadores
    resources :fretes
    resources :cotacoes
    resources :propostas
  end
end
