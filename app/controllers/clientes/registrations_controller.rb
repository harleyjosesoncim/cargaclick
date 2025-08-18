# frozen_string_literal: true

class Clientes::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]
  before_action :configure_account_update_params, only: [:update]

  protected

  # Redireciona após cadastro concluído
  def after_sign_up_path_for(resource)
    sucesso_cadastro_path || root_path
  end

  # Redireciona após atualização de perfil
  def after_update_path_for(resource)
    cliente_dashboard_path || root_path
  end

  # Permitir campos extras no cadastro
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nome, :telefone, :cpf])
  end

  # Permitir campos extras na atualização
  def configure_account_update_params
    devise_parameter_sanitizer.permit(:account_update, keys: [:nome, :telefone, :cpf])
  end
end

