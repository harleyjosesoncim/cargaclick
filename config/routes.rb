# frozen_string_literal: true

Rails.application.routes.draw do
  # =====================================================
  # ROOT (HOME)
  # =====================================================
  # Página inicial pública
  root "home#index"

  # =====================================================
  # PÁGINAS INSTITUCIONAIS (PÚBLICAS / ESTÁTICAS)
  # =====================================================
  # Centraliza páginas simples no HomeController
  scope controller: :home do
    get :about
    get :contato
    get :fidelidade
    get :relatorios
  end

  # =====================================================
  # CLIENTES
  # =====================================================
  # Estratégia:
  # - new / create → cadastro público
  # - show / edit / update → área autenticada
  # - index / destroy → administrativo
  #
  # Evita conflito de rotas e mantém clareza sem quebrar helpers
  resources :clientes, except: [:new, :create] do
    collection do
      get  :new
      post :create
    end
  end

  # =====================================================
  # TRANSPORTADORES
  # =====================================================
  # Cadastro público separado (landing / formulário)
  # Não conflita com REST nem com Devise
  get "/transportadores/cadastro",
      to: "transportadores#cadastro",
      as: :cadastro_transportador

  # Painel, edição e gestão
  # new/create ficam fora (cadastro público acima)
  resources :transportadores, except: [:new, :create]

# Rota estável para simulação de frete (usada na HOME)
get "/simular-frete", to: "fretes#new", as: :simular_frete



  # =====================================================
  # FRETES (🔥 NÚCLEO DO CARGACLICK 🔥)
  # =====================================================
  # ⚠️ SEÇÃO CRÍTICA – NÃO REMOVER
  #
  # Garante:
  # - new_frete_path
  # - frete_path
  # - fretes_path
  # - pagar_frete_path
  #
  # Evita:
  # - erro 500 na home
  # - quebra de view
  # - falha no fluxo de simulação
  #
  # Sustenta:
  # - cálculo por CEP / localização
  # - integração com cotação e pagamento
  resources :fretes do
    member do
      get :pagar
    end
  end

  # =====================================================
  # API (ISOLADA – SEM IMPACTO NO HTML)
  # =====================================================
  # Nunca deve interferir nas rotas públicas
  namespace :api, defaults: { format: :json } do
    namespace :transportadores do
      post :optin
    end
  end

  # =====================================================
  # HEALTH CHECK (BOA PRÁTICA DE PRODUÇÃO)
  # =====================================================
  # Usado por monitoramento / load balancer
  get "/health", to: proc { [200, {}, ["OK"]] }

  # =====================================================
  # FALLBACK DE SEGURANÇA (ANTI-CRASH)
  # =====================================================
  # Evita:
  # - erro 500 por rota inexistente
  # - spam de bots (/.well-known, etc.)
  #
  # Redireciona para home com UX aceitável
  match "*path", to: redirect("/"), via: :all
end
