Rails.application.routes.draw do
  # ================================
  # TRANSPORTADORES
  # ================================

  # Formulário de cadastro (GET)
  get "/transportadores/cadastro", to: "transportadores#cadastro"

  # Opt-in / criação via API (POST)
  post "/api/transportadores/optin", to: "transportadores#optin"

  # ================================
  # MIGRAÇÃO DISCORD → CARGACLICK
  # ================================

  # Página de confirmação (SIM → cadastro)
  get "/migracao/discord", to: "migracao#discord"
end
