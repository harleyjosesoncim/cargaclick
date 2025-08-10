# frozen_string_literal: true

Rails.application.routes.draw do
  resources :propostas do
  member do
    get :gerar_proposta_inteligente
  end
end

  devise_for :clientes
  resources :modals
  # Página inicial da aplicação
  root 'home#index'

  # Rotas para Fretes
  resources :fretes do
    # Rotas de membro para Fretes
    member do
      # Rota para rastrear um frete específico
      get :rastreamento
      # Rota para marcar um frete como entregue (requer método POST)
      post :entregar
      # ✅ Rota para acessar o chat de um frete específico
      get :chat
    end

    # Rotas de coleção para Fretes
    collection do
      # Rota para listar os fretes do usuário logado (ou associados)
      get :meus
    end
  end

  # Rotas para Clientes
  resources :clientes do
    # Rotas aninhadas para Fidelidade de Clientes
    member do
      get 'fidelidade', to: 'fidelidade#cliente', as: 'fidelidade'
    end
  end

  # Rotas para Transportadores
  resources :transportadores do
    # Rotas aninhadas para Fidelidade de Transportadores
    member do
      get 'fidelidade', to: 'fidelidade#transportador', as: 'fidelidade'
    end
  end
  # Rota para a página de Configurações do Admin

  get 'admin/dashboard', to: 'admin#dashboard'
  # Rota para o Painel do Cliente
  # Rota para o Bolsão de solicitações
  get 'bolsao', to: 'bolsao#index', as: 'bolsao'

  # Rota para o Ranking geral
  get 'ranking', to: 'ranking#index', as: 'ranking'

  post 'fretes/:id/gerar_proposta', to: 'fretes#gerar_proposta', as: 'gerar_proposta_frete'

  post 'gerar_post_instagram', to: 'marketing#gerar_post_instagram'
  post 'gerar_email_marketing', to: 'marketing#gerar_email_marketing'
  post 'gerar_proposta_comercial', to: 'marketing#gerar_proposta_comercial'
# Rotas para Marketing

  # Rotas para o Painel Administrativo
  namespace :admin do
    # Rota para a página inicial do admin
    get '/', to: 'dashboard#index', as: 'index'
    # Rota para atualizar configurações ou dados do admin
    patch 'update', to: 'dashboard#update', as: 'update'
    # Adicione outras rotas de admin aqui conforme necessário
  end
end
