# frozen_string_literal: true

Rails.application.routes.draw do
  # 1. ÁREAS RESTRITAS (DASHBOARDS)
  namespace :clientes do
    root to: "dashboards#index"
  end

  namespace :transportadores do
    root to: "dashboards#index"
  end

  # 2. PÁGINA INICIAL
  root "home#index"

  # 3. FRETES - O QUE ESTÁ CORRIGINDO O ERRO 500
  # Definimos o nome 'simular_frete' aqui para o link da Home funcionar
  get "/simular-frete", to: "fretes#new", as: :simular_frete
  
  resources :fretes, except: [:index] do
    member do
      get :pagar
    end
  end

  # Redirecionamento de segurança
  get "/fretes", to: redirect("/simular-frete")

  # 4. OUTRAS FUNCIONALIDADES (LOGIN E CADASTRO)
  # Aqui entram as rotas do Devise e dos outros recursos que você já tem
  # (Mantenha o restante do código que já estava no arquivo antes)
  
  # ... (Páginas institucionais, APIs, etc.)

  # 5. FALLBACK (SEMPRE POR ÚLTIMO)
  match "*path", to: redirect("/"), via: :all, constraints: lambda { |req|
    req.path.exclude? 'rails/active_storage'
  }
end