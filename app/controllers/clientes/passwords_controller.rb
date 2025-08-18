class Clientes::PasswordsController < Devise::PasswordsController
  respond_to :html, :turbo_stream
end
