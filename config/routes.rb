# config/routes.rb
Rails.application.routes.draw do
  # Healthcheck para monitoramento (ex.: Render/uptime checks)
  get 'up', to: 'rails/health#show', as: :rails_health_check

  # Página inicial
  root to: 'home#index'

  # Configuração do Devise para autenticação de clientes
  devise_for :clientes,
             path: 'clientes',
             controllers: {
               sessions: 'clientes/sessions',
               registrations: 'clientes/registrations',
               passwords: 'clientes/passwords'
             }

  # Rotas de negócio
  resources :fretes

  # Áreas autenticadas (opcional, descomente e ajuste conforme necessário)
  # authenticate :cliente do
  #   get 'dashboard', to: 'dashboard#show', as: :cliente_dashboard
  #   resources :minhas_viagens, only: [:index, :show]
  # end

  # Fallback para 404 (opcional, descomente se desejar)
  # get '*unmatched', to: 'errors#not_found', via: :all
end