# frozen_string_literal: true

class Clientes::RegistrationsController < Devise::RegistrationsController

  protected

  # Redireciona após cadastro concluído
  def after_sign_up_path_for(resource)
    sucesso_cadastro_path  # <-- Caminho da tela de sucesso
  end

  # Caso queira permitir campos extras no cadastro (ex: nome)
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nome])
  end

end
