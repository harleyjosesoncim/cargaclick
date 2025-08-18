# config/routes.rb
Rails.application.routes.draw do
  # ====== Healthcheck / Rails 7 ======
  # Útil para Render/uptime checks
  get "up" => "rails/health#show", as: :rails_health_check

  # ====== Home ======
  root "home#index"

  # ====== Autenticação (Devise - Clientes) ======
  # IMPORTANTE: uma ÚNICA definição, sem devise_scope manual e sem skip de :sessions
  devise_for :clientes,
             path: "clientes",
             controllers: {
               sessions:      "clientes/sessions",
               registrations: "clientes/registrations",
               passwords:     "clientes/passwords"
               # Se você tiver criado:
               # confirmations: "clientes/confirmations",
               # unlocks:       "clientes/unlocks"
             }

  # ====== Rotas de negócio ======
  # Deixe os controllers cuidarem do acesso (ex.: before_action :authenticate_cliente!)
  resources :fretes
  # resources :transportadores  # (se existir)
  # resources :clientes, only: [:index, :show] # (se tiver área pública/listagens)

  # ====== Exemplo de área autenticada (opcional) ======
  # Se quiser rotas que só existem para cliente logado, use authenticate:
  # authenticate :cliente do
  #   get "dashboard", to: "dashboard#show", as: :cliente_dashboard
  #   resources :minhas_viagens, only: [:index, :show]
  # end

  # ====== Admin (opcional; descomente só se usar) ======
  # Se usar rails_admin:
  # mount RailsAdmin::Engine => "/admin", as: "rails_admin"

  # Se usar Devise também para Admin:
  # devise_for :admins,
  #   path: "admin",
  #   controllers: {
  #     sessions:      "admin/sessions",
  #     registrations: "admin/registrations",
  #     passwords:     "admin/passwords"
  #   }

  # ====== Fallback 404 elegante (opcional) ======
  # Isto envia qualquer rota desconhecida para uma página 404 customizada.
  # get "*unmatched", to: "errors#not_found", via: :all
end

