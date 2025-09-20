# frozen_string_literal: true

Rails.application.routes.draw do
  # ===============================================================
  # AUTENTICAÇÃO (Devise + ActiveAdmin)
  # ===============================================================
  devise_for :transportadores
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  devise_for :clientes,
             path: "clientes",
             controllers: {
               sessions:      "clientes/sessions",
               registrations: "clientes/registrations",
               passwords:     "clientes/passwords"
             }

  # ===============================================================
  # HEALTHCHECK
  # ===============================================================
  get "up", to: "rails/health#show", as: :rails_health_check

  # ===============================================================
  # PÁGINAS PÚBLICAS
  # ===============================================================
  get "home",       to: "home#index",      as: :home
  get "sobre",      to: "home#about",      as: :about   # corrigido
  get "fidelidade", to: "home#fidelidade", as: :fidelidade
  get "contato",    to: "contatos#new",    as: :contato

  # ===============================================================
  # FORMULÁRIO DE CONTATO
  # ===============================================================
  resources :contatos, only: [:new, :create]

  # ===============================================================
  # ROOTS
  # ===============================================================
  authenticated :cliente do
    root "fretes#index", as: :authenticated_root
  end

  unauthenticated do
    root "home#index", as: :unauthenticated_root
  end

  root "home#index"

  # ===============================================================
  # CLIENTES & TRANSPORTADORES
  # ===============================================================
  resources :clientes do
    resources :fretes, only: [:index]
  end

  resources :transportadores do
    member do
      get :fidelidade
    end

    resources :cotacoes,   only: [:index]
    resources :pagamentos, only: [:index]
  end

  # ===============================================================
  # FRETES & COTAÇÕES
  # ===============================================================
  resources :fretes do
    resources :cotacoes, only: [:index, :new, :create]

    resources :messages, only: [:index, :create] do
      member do
        patch :mark_as_read
        patch :mark_as_important
      end
    end

    resources :pagamentos, only: [:index, :create]

    member do
      get :pagar
      get :status
    end
  end

  resources :cotacoes, only: [:index, :show, :edit, :update, :destroy] do
    member do
      post :aceitar
      post :recusar
    end
  end

  # ===============================================================
  # PROPOSTAS
  # ===============================================================
  resources :propostas do
    member do
      get :gerar_proposta_inteligente
      get :bolsa
    end
  end

  # ===============================================================
  # OUTROS MÓDULOS
  # ===============================================================
  resources :modals
  resources :veiculos
  resources :cargas
  resources :tipos_cargas
  resources :unidades_medidas

  # ===============================================================
  # AVALIAÇÕES
  # ===============================================================
  resources :avaliacoes, only: [:index, :new, :create, :show]

  # ===============================================================
  # ATALHOS
  # ===============================================================
  get "fretes/novo",     to: "fretes#new",   as: :novo_frete
  get "bolsao",          to: "fretes#queue", as: :bolsao_solicitacoes
  get "calcular_fretes", to: "fretes#new",   as: :calcular_fretes

  # ===============================================================
  # PAGAMENTOS GLOBAIS
  # ===============================================================
  resources :pagamentos, only: [:index, :show, :create] do
    member do
      post  :checkout
      patch :cancelar
    end

    collection do
      get  :retorno
      post :webhook
      get  :ping
      get  :sucesso
      get  :falha
      get  :pendente
    end
  end

  # ===============================================================
  # RELATÓRIOS
  # ===============================================================
  get "relatorios",              to: "relatorios#index",        as: :relatorios
  get "relatorios/ganhos",       to: "relatorios#ganhos",       as: :relatorios_ganhos
  get "relatorios/estatisticas", to: "relatorios#estatisticas", as: :relatorios_estatisticas
end
