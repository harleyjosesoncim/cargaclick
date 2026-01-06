# frozen_string_literal: true

Rails.application.routes.draw do
  # =====================================================
  # ROOT (HOME)
  # =====================================================
  root "home#index"

  # =====================================================
  # PÁGINAS INSTITUCIONAIS (PÚBLICAS / ESTÁTICAS)
  # =====================================================
  scope controller: :home do
    get :about
    get :contato
    get :fidelidade
    get :relatorios
  end

  # =====================================================
  # CLIENTES
  # =====================================================
  # Obs:
  # - new/create → cadastro público
  # - show/edit/update → área do cliente (autenticada)
  # - index/destroy → uso administrativo
  resources :clientes, except: [:new, :create] do
    collection do
      get  :new
      post :create
    end
  end

  # =====================================================
  # TRANSPORTADORES
  # =====================================================
  # Cadastro público separado (não conflita com REST)
  get "/transportadores/cadastro",
      to: "transportadores#cadastro",
      as: :cadastro_transportador

  # Painel e gestão (admin / transportador)
  resources :transportadores, except: [:new, :create]

  # =====================================================
  # FRETES (🔥 LÓGICA CENTRAL DO SISTEMA 🔥)
  # =====================================================
  # Esta seção é CRÍTICA:
  # - garante existência de new_frete_path
  # - evita erro 500 na home
  # - sustenta cálculo por localização
  resources :fretes do
    member do
      get :pagar
    end
  end

  # =====================================================
  # API (ISOLADA – SEM IMPACTO NO HTML)
  # =====================================================
  namespace :api, defaults: { format: :json } do
    namespace :transportadores do
      post :optin
    end
  end

  # =====================================================
  # FALLBACK DE SEGURANÇA (EVITA ERRO 500 POR ROTA INVÁLIDA)
  # =====================================================
  # Qualquer rota inexistente redireciona para a home
  # (melhor UX e evita crashes em produção)
  match "*path", to: redirect("/"), via: :all
end
