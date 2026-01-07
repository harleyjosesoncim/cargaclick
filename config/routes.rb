# config/routes.rb

# Garante que o helper simular_frete_path exista
get "/simular-frete", to: "fretes#new", as: :simular_frete

# Redireciona a rota antiga para evitar erros de digitagem no navegador
get "/fretes", to: redirect("/simular-frete")

resources :fretes, except: [:index] do
  member do
    get :pagar
  end
end