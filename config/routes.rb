Rails.application.routes.draw do
  # === HEALTHCHECK =============================================
  get "up", to: "rails/health#show", as: :rails_health_check

  # === AUTENTICAÇÃO (clientes via Devise) ======================
  devise_for :clientes,
             path: "clientes",
             controllers: {
               sessions:      "clientes/sessions",
               registrations: "clientes/registrations",
               passwords:     "clientes/passwords"
             }

  # === PÁGINAS PÚBLICAS ========================================
  get "home",    to: "home#index"
  get "sobre",   to: "home#about",   as: :about
  get "contato", to: "home#contact", as: :contact         

  # === ROOTS ===================================================
  authenticated :cliente do
    root "fretes#index", as: :authenticated_root
  end

  unauthenticated do
    root "home#index", as: :unauthenticated_root
  end

  # 🔑 Root global (garante root_path sempre funcional)
  root "home#index"

  # === RECURSOS PRINCIPAIS =====================================
  resources :clientes
  resources :transportadores

  # 🚚 Fretes + Cotações
  resources :fretes do
    resources :cotacoes, only: [:index, :new, :create]
  end

  resources :cotacoes, only: [:index, :show, :edit, :update, :destroy]

  # === PROPOSTAS ===============================================
  resources :propostas do
    member do
      get :gerar_proposta_inteligente
    end
  end

  # === OUTROS MÓDULOS ==========================================
  resources :modals
  resources :veiculos
  resources :cargas
  resources :tipos_cargas
  resources :unidades_medidas

  # === ATALHOS / ALIASES =======================================
  get "fretes/novo", to: "fretes#new",   as: :novo_frete
  get "bolsao",      to: "fretes#queue", as: :bolsao_solicitacoes

  # === PAINEL ADMIN ============================================
  namespace :admin do
    root to: "dashboard#index"   # cria admin_root_path
  end
end
