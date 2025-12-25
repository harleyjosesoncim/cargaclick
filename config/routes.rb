# frozen_string_literal: true

Rails.application.routes.draw do
  # ===============================================================
  # LANDING PAGE
  # ===============================================================
  # Rota direta para a landing (se quiser usar /landing)
  get "landing", to: "landing#index", as: :landing

  # ===============================================================
  # AUTENTICAÇÃO (Devise + ActiveAdmin)
  # ===============================================================
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  devise_for :transportadores,
             path: "transportadores",
             controllers: {
               sessions:      "transportadores/sessions",
               registrations: "transportadores/registrations",
               passwords:     "transportadores/passwords",
               confirmations: "transportadores/confirmations"
             },
             path_names: { sign_in: "entrar", sign_out: "sair", sign_up: "cadastro" },
             sign_out_via: [:delete, :get]

  devise_for :clientes,
             path: "clientes",
             controllers: {
               sessions:      "clientes/sessions",
               registrations: "clientes/registrations",
               passwords:     "clientes/passwords",
               confirmations: "clientes/confirmations"
             },
             path_names: { sign_in: "entrar", sign_out: "sair", sign_up: "cadastro" },
             sign_out_via: [:delete, :get]

  # ===============================================================
  # HEALTHCHECK
  # ===============================================================
  get "up", to: "rails/health#show", as: :rails_health_check

  # ===============================================================
  # PÁGINAS PÚBLICAS
  # ===============================================================
  get "home",       to: "home#index",      as: :home
  get "sobre",      to: "home#about",      as: :about
  get "fidelidade", to: "home#fidelidade", as: :fidelidade
  get "contato",    to: "contatos#new",    as: :contato

  # ===============================================================
  # ROOTS
  # ===============================================================
  # Cliente autenticado continua indo para o index de fretes
  authenticated :cliente do
    root "fretes#index", as: :authenticated_root
  end

  # Visitante (não autenticado) agora cai na LANDING
  unauthenticated do
    root "landing#index", as: :unauthenticated_root
  end

  # ===============================================================
  # CONTATO
  # ===============================================================
  resources :contatos, only: %i[new create]

  # ===============================================================
  # RELATÓRIOS (novo)
  # ===============================================================
  resources :relatorios, only: [:index] do
    collection do
      get :ganhos
      get :avaliacoes
      get :estatisticas
    end
  end

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
  # FRETES, COTAÇÕES, MENSAGENS
  # ===============================================================
  resources :fretes do
    resources :cotacoes, only: %i[index new create]

    resources :messages, only: %i[index create] do
      member do
        patch :mark_as_read
        patch :mark_as_important
      end
    end

    resources :pagamentos, only: %i[index create]

    member do
      get :pagar
      get :status
    end
  end

  resources :cotacoes, only: %i[index show edit update destroy] do
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
  resources :avaliacoes, only: %i[index new create show]

  # ===============================================================
  # ATALHOS
  # ===============================================================
  get "fretes/novo",     to: "fretes#new",   as: :novo_frete
  get "bolsao",          to: "fretes#queue", as: :bolsao_solicitacoes
  get "calcular_fretes", to: "fretes#new",   as: :calcular_fretes

  # ===============================================================
  # PAGAMENTOS (GLOBAL)
  # ===============================================================
  resources :pagamentos, only: %i[index show create update] do
    member do
      patch :cancelar
      post  :liberar
    end
    collection do
      post :checkout
      get  :retorno
      post :webhook
      get  :ping
      get  :sucesso
      get  :falha
      get  :pendente
    end
  end
end
