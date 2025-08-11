#!/usr/bin/env ruby
# frozen_string_literal: true

# 1) Define the content for config/routes.rb (only the Rails routes configuration)
routes_content = <<~RUBY
  # frozen_string_literal: true

  Rails.application.routes.draw do
    # Canonical redirect: apex -> www
    constraints(host: "cargaclick.com.br") do
      match "/", to: redirect("https://www.cargaclick.com.br/"), via: :all
      match "(*path)", to: redirect { |p, req|
        qs = req.query_string.to_s
        "https://www.cargaclick.com.br/\#{p[:path]}\#{qs.empty? ? "" : "?\#{qs}"}"
      }, via: :all
    end

    # Health check
    get "up" => "rails/health#show", as: :rails_health_check

    # Página inicial
    root "home#index"

    # Devise
    devise_for :clientes, controllers: {
      registrations: "clientes/registrations",
      sessions: "clientes/sessions",
      passwords: "clientes/passwords"
    }
    devise_for :transportadores, controllers: {
      registrations: "transportadores/registrations",
      sessions: "transportadores/sessions",
      passwords: "transportadores/passwords"
    }

    # Propostas
    resources :propostas do
      member { get :gerar_proposta_inteligente }
    end

    # Modals
    resources :modals

    # Fretes
    resources :fretes do
      member do
        get :rastreamento
        post :entregar
        get :chat
      end
      collection { get :meus }
    end

    # Clientes
    resources :clientes do
      member { get "fidelidade", to: "fidelidade#cliente", as: "fidelidade" }
    end

    # Transportadores
    resources :transportadores do
      member { get "fidelidade", to: "fidelidade#transportador", as: "fidelidade" }
    end

    # Admin
    get "admin/dashboard", to: "admin/dashboard#index"
    namespace :admin do
      get "/", to: "dashboard#index", as: "index"
      patch "update", to: "dashboard#update", as: "update"
    end

    # Bolsão & Ranking
    get "bolsao", to: "bolsao#index", as: "bolsao"
    get "ranking", to: "ranking#index", as: "ranking"

    # Ações extra
    post "fretes/:id/gerar_proposta", to: "fretes#gerar_proposta", as: "gerar_proposta_frete"

    # Marketing
    post "gerar_post_instagram", to: "marketing#gerar_post_instagram"
    post "gerar_email_marketing", to: "marketing#gerar_email_marketing"
    post "gerar_proposta_comercial", to: "marketing#gerar_proposta_comercial"
  end
RUBY

# 2) Change to project directory
project_dir = File.expand_path("~/projects/Cargaclick")
Dir.chdir(project_dir) do
  # 3) Write the routes content to config/routes.rb
  File.write("config/routes.rb", routes_content)

  # 4) Check syntax of the routes file
  syntax_check = system("ruby -c config/routes.rb")
  unless syntax_check
    puts "Erro: Sintaxe inválida em config/routes.rb"
    exit 1
  end

  # 5) Perform Git operations
  system("git add config/routes.rb")
  system('git commit -m "hotfix(routes): fix syntax error in routes.rb for Render build"')
  system("git push origin main")
end

puts "Tarefa concluída: Arquivo routes.rb corrigido, sintaxe verificada, comitado e enviado.""