Rails.application.routes.draw do
  # --- Admin ---
  devise_for :admin_users, ActiveAdmin::Devise.config
  ActiveAdmin.routes(self)

  # --- Auth (Devise) ---
  devise_for :clientes, controllers: {
    sessions:      "clientes/sessions",
    registrations: "clientes/registrations",
    passwords:     "clientes/passwords",
    confirmations: "clientes/confirmations"
  }

  devise_for :transportadores, controllers: {
    sessions:      "transportadores/sessions",
    registrations: "transportadores/registrations",
    passwords:     "transportadores/passwords",
    confirmations: "transportadores/confirmations"
  }

  # --- Landing / Menu inicial ---
  root "landing#index"
  get "/inicio", to: "landing#index", as: :inicio

  # --- Páginas públicas ---
  get "/sobre",   to: "pages#about",  as: :sobre
  get "/contato", to: "contatos#new", as: :contato

  # Alias compatível (evita quebrar links antigos)
  get "/about",   to: "pages#about",   as: :about
  get "/contact", to: "pages#contact", as: :contact

  # Fidelidade (pública + painéis)
  get "/fidelidade",               to: "home#fidelidade", as: :fidelidade
  get "/fidelidade/cliente",       to: "fidelidade#cliente", as: :fidelidade_cliente
  get "/fidelidade/transportador", to: "fidelidade#transportador", as: :fidelidade_transportador

  # Relatórios
  get  "/relatorios",             to: "relatorios#index",        as: :relatorios
  get  "/relatorios/ganhos",      to: "relatorios#ganhos",       as: :relatorios_ganhos
  get  "/relatorios/avaliacoes",  to: "relatorios#avaliacoes",   as: :relatorios_avaliacoes
  get  "/relatorios/estatisticas",to: "relatorios#estatisticas", as: :relatorios_estatisticas
  post "/relatorios/periodo",     to: "relatorios#set_periodo",  as: :relatorios_set_periodo

  # --- Ação principal ---
  get "/simular-frete", to: "fretes#new", as: :simular_frete

  # Conveniência (URLs do menu, sem looping)
  get "/cliente",       to: redirect("/clientes")
  get "/transportador", to: redirect("/transportadores")

  # Dashboards (painéis)
  namespace :clientes do
    root to: "dashboards#index"
  end

  namespace :transportadores do
    root to: "dashboards#index"
  end

  # --- Fretes ---
  # GET /fretes vira entrada para simulação (mas POST /fretes continua para create)
  get "/fretes", to: redirect("/simular-frete"), as: :fretes

  resources :fretes, except: [:index] do
    member do
      get :chat
      get :rastreamento
    end
  end

  # Outros recursos usados por telas
  resources :cotacoes
  resources :pagamentos
  resources :propostas
  resources :chats, only: %i[index show create]
  resources :messages, only: %i[create]

  # Bolsão
  get "/bolsao", to: "bolsao#index", as: :bolsao
end
