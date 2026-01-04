Rails.application.routes.draw do
  root to: redirect("/migracao/discord")

  get "/migracao/discord", to: "migracao#discord"

  get  "/transportadores/cadastro", to: "transportadores#cadastro"
  post "/api/transportadores/optin", to: "transportadores#optin"
end
