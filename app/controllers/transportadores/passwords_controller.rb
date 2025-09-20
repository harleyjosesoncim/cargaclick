class Transportadores::PasswordsController < Devise::PasswordsController
  protected

  def after_resetting_password_path_for(resource)
    sucesso_senha_path
  end
end
