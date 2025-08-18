Rails.application.routes.draw do
  root "home#index"

  devise_for :clientes,
             path: "clientes",
             controllers: {
               sessions: "clientes/sessions",
               registrations: "clientes/registrations",
               passwords: "clientes/passwords"
             }

  resources :fretes
end
