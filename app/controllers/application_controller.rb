# frozen_string_literal: true

class ApplicationController < ActionController::Base
  helper NavigationHelper
end


class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  add_flash_types :success, :warning, :info

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  # Devise: parâmetros extras
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[nome telefone cpf])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[nome telefone cpf])
  end

  # Redirecionamento pós-login
  def after_sign_in_path_for(resource)
    return admin_root_path if resource.is_a?(AdminUser)
    return transportadores_root_path if resource.is_a?(Transportador)
    return clientes_root_path if resource.is_a?(Cliente)

    root_path
  end
end
