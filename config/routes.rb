Rails.application.routes.draw do
  root to: redirect("/migracao/discord")

  get "/migracao/discord", to: "migracao#discord"

  get  "/transportadores/cadastro", to: "transportadores#cadastro"
  post "/api/transportadores/optin", to: "transportadores#optin"
end
Rails.application.routes.draw do
  root "home#index"

  # Rotas básicas para não quebrar a home
  get "/fretes/novo", to: "home#placeholder", as: :new_frete
  get "/fidelidade",  to: "home#placeholder", as: :fidelidade
  get "/relatorios",  to: "home#placeholder", as: :relatorios
  get "/about",       to: "home#placeholder", as: :about
  get "/contato",     to: "home#placeholder", as: :contato
end
