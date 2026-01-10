# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  add_flash_types :success, :warning, :info

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[nome telefone cpf])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[nome telefone cpf])
  end

  def after_sign_in_path_for(resource)
    case resource
    when AdminUser
      admin_root_path
    when Transportador
      respond_to?(:transportadores_root_path) ? transportadores_root_path : root_path
    when Cliente
      respond_to?(:clientes_root_path) ? clientes_root_path : root_path
    else
      super
    end
  end
end
