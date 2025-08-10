Rails.application.routes.draw do
  # Página inicial
  root 'home#index'

  # Rota de sucesso para senha
  get '/senha/sucesso', to: 'shared#success_password', as: 'sucesso_senha'

  # Autenticação Devise - CLIENTES
  devise_for :clientes, controllers: {
    registrations: 'clientes/registrations',
    sessions: 'clientes/sessions',
    passwords: 'clientes/passwords'
  }

  # Autenticação Devise - TRANSPORTADORES
  devise_for :transportadores, controllers: {
    registrations: 'transportadores/registrations',
    sessions: 'transportadores/sessions',
    passwords: 'transportadores/passwords'
  }

  # Perfil de Clientes e Transportadores (show, edit, update)
  resources :clientes, only: [:show, :edit, :update]
  resources :transportadores, only: [:show, :edit, :update]

  # Fretes com rotas customizadas
  resources :fretes do
    member do
      get :rastreamento
      post :entregar
      get :chat
    end
  end

  # Cotações
  resources :cotacoes

  # Propostas com rota customizada para GPT

resources :propostas do
  member do
    get :gerar_proposta_inteligente
  end
end

get 'cadastro/transportador', to: 'transportadores#cadastro_publico', as: 'cadastro_transportador'
post 'cadastro/transportador', to: 'transportadores#criar_publico'

   # rota para gerar proposta comercial de frete

  # Bolsão de Solicitações
  get '/bolsao', to: 'bolsao#index', as: 'bolsao'

  # Ranking de Transportadores
  get '/ranking', to: 'ranking#index', as: 'ranking'

  # Fidelidade
  get '/fidelidade', to: 'fidelidade#index', as: 'fidelidade'

  # Simulador de Frete
  get '/simulador', to: 'simulador#index', as: 'simulador'
  post '/simulador/calcular', to: 'simulador#calcular', as: 'calcular_simulador'

  # Modais de Transporte
  resources :modals, only: [:index, :new, :create, :edit, :update, :destroy]

  # Pagamento
  get '/pagamento/:id', to: 'pagamento#show', as: 'pagamento'

  # Admin Dashboard
  get '/admin', to: 'admin#index', as: 'admin'

  # Tela de Sucesso após Cadastro
  get '/cadastro/sucesso', to: 'clientes#sucesso', as: 'sucesso_cadastro'
end
