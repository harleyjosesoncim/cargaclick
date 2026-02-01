# frozen_string_literal: true

Rails.application.routes.draw do
  # =====================================================
  # 🔐 ADMINISTRAÇÃO DO SISTEMA
  # =====================================================
  # Área exclusiva para administração interna da plataforma
  # Utiliza ActiveAdmin + Devise
  # Acesso restrito (gestão de usuários, fretes, métricas etc.)
  # =====================================================
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # =====================================================
  # 🔐 AUTENTICAÇÃO — CLIENTES (Devise)
  # =====================================================
  # Clientes são os solicitantes de frete
  # Possuem fluxo próprio de login, cadastro, senha e confirmação
  # Controllers customizados para permitir UX diferenciada
  # =====================================================
  devise_for :clientes, controllers: {
    sessions:      "clientes/sessions",
    registrations: "clientes/registrations",
    passwords:     "clientes/passwords",
    confirmations: "clientes/confirmations"
  }

  # =====================================================
  # 🔐 AUTENTICAÇÃO — TRANSPORTADORES (Devise)
  # =====================================================
  # Transportadores são prestadores independentes (PF ou PJ)
  # Fluxo separado de clientes para evitar conflitos de regra
  # Controllers próprios para evolução futura (fidelidade, ganhos, ranking)
  # =====================================================
  devise_for :transportadores, controllers: {
    sessions:      "transportadores/sessions",
    registrations: "transportadores/registrations",
    passwords:     "transportadores/passwords",
    confirmations: "transportadores/confirmations"
  }

  # =====================================================
  # 🏠 LANDING PAGE / HOME
  # =====================================================
  # Página institucional principal
  # Função: conversão + explicação do produto
  # =====================================================
  root "pages#home"
  get "/inicio", to: "pages#home", as: :inicio

  namespace :transportadores do
  get "/", to: "landing#index"
end

  # =====================================================
  # 🏢 PÁGINAS INSTITUCIONAIS
  # =====================================================
  # Conteúdo estático / institucional
  # =====================================================
  get "/sobre",   to: "pages#about",  as: :sobre
  get "/contato", to: "contatos#new", as: :contato

  # =====================================================
  # 🚚 SIMULAÇÃO DE FRETE (PÚBLICA)
  # =====================================================
  # Entrada principal do funil
  # Qualquer usuário pode simular frete sem login
  # POST separado para cálculo e validação
  # =====================================================
  get  "/simular-frete", to: "fretes#new",     as: :simular_frete
  post "/simular-frete", to: "fretes#simular", as: :simular_frete_post

  # =====================================================
  # 👤 CLIENTES — DASHBOARD E CADASTRO PROGRESSIVO
  # =====================================================
  # Namespace isolado para evitar colisão de rotas
  # Cadastro em etapas (onboarding guiado)
  # =====================================================
  namespace :clientes do
    # Painel principal do cliente autenticado
    get "dashboard", to: "dashboards#index", as: :dashboard

    # Fluxo de complementação de cadastro
    # Usado quando o cliente se cadastra rápido (após simulação)
    get  "completar_cadastro",  to: "cadastro#edit",   as: :completar_cadastro
    patch "finalizar_cadastro", to: "cadastro#update", as: :finalizar_cadastro
  end

  # =====================================================
  # 🚛 TRANSPORTADORES — DASHBOARD E PERFIL
  # =====================================================
  # Área exclusiva do transportador
  # Não existe vínculo empregatício (prestador independente)
  # Estrutura preparada para ganhos, fidelidade e reputação
  # =====================================================
  namespace :transportadores do
    # Painel principal do transportador autenticado
    get "dashboard", to: "dashboards#index", as: :dashboard

    # Completar perfil profissional
    # Dados do veículo, área de atuação, valores, documentos
    get  "completar_perfil",  to: "cadastro#edit",   as: :completar_perfil
    patch "atualizar_perfil", to: "cadastro#update", as: :atualizar_perfil
  end

  # =====================================================
  # 📦 FRETES — CORE DO SISTEMA
  # =====================================================
  # Entidade central da plataforma
  # Relaciona clientes, transportadores e pagamentos
  # =====================================================
  resources :fretes do
    member do
      # Comunicação direta cliente ↔ transportador
      get :chat

      # Rastreamento e acompanhamento do frete
      get :rastreamento
    end
  end

  # =====================================================
  # 🚫 FALLBACK — ERRO 404 CONTROLADO
  # =====================================================
  # Captura qualquer rota inexistente
  # Evita páginas de erro padrão do Rails
  # =====================================================
  match "*path", to: "errors#not_found", via: :all
end
