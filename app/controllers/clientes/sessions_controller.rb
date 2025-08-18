class Clientes::SessionsController < Devise::SessionsController
  respond_to :html, :turbo_stream
end
