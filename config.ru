Rails.application.routes.draw do
  root "home#index"
  get "/healthcheck", to: proc { [200, {}, ["OK"]] }
end
