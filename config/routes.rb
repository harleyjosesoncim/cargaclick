# frozen_string_literal: true

Rails.application.routes.draw do
  # =========================================================
  # 1) ÁREAS RESTRITAS (DASHBOARDS)
  # =========================================================
  namespace :clientes do
    root to: "dashboards#index", as: :dashboard
  end

  namespace :transportadores do
    root to: "dashboards#index", as: :dashboard
  end

  # =========================================================
  # 2) PÁGINAS PÚBLICAS (HOME / INSTITUCIONAL)
  # =========================================================
  root "home#index"

  get "/sobre",      to: "home#about",      as: :sobre
  get "/contato",    to: "home#contato",    as: :contato
  get "/fidelidade", to: "home#fidelidade", as: :fidelidade
  get "/relatorios", to: "home#relatorios", as: :relatorios

  # =========================================================
  # 3) SIMULAÇÃO DE FRETE (ROTA CANÔNICA)
  # =========================================================
  # Helper principal: simular_frete_path
  get "/simular-frete", to: "fretes#new", as: :simular_frete

  resources :fretes, except: [:index] do
    member do
      get :pagar
    end
  end

  # Redirecionamento defensivo (URL antiga)
  get "/fretes", to: redirect("/simular-frete")

  # =========================================================
  # 4) HEALTHCHECK (monitoramento Render / UptimeRobot)
  # =========================================================
  get "/up", to: proc { [200, { "Content-Type" => "text/plain" }, ["OK"]] }

  # =========================================================
  # 5) FALLBACK (SEMPRE POR ÚLTIMO)
  # =========================================================
  match "*path",
        to: redirect("/"),
        via: :all,
        constraints: ->(req) { !req.path.start_with?("/rails/active_storage") }
end
