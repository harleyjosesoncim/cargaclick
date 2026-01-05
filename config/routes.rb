Rails.application.routes.draw do
  # ROOT ÚNICO DO SISTEMA
  root to: "home#index"

  # Páginas institucionais
  get "/about",      to: "home#about",      as: :about
  get "/contato",    to: "home#contato",    as: :contato
  get "/fidelidade", to: "home#fidelidade", as: :fidelidade
  get "/relatorios", to: "home#relatorios", as: :relatorios

  # ⚠️ IMPORTANTE
  # Se existir namespace/admin, NÃO use root lá dentro
  # use algo como:
  # get "/admin", to: "admin/dashboard#index", as: :admin_root
end
