Rails.application.routes.draw do
  get "up" => "rails/health#show", as: :rails_health_check

  # Define a rota principal
  root "clientes#index"

  # Outras rotas aqui...
end

