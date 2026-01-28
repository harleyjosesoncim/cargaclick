# frozen_string_literal: true

class Transportadores::RegistrationsController < Devise::RegistrationsController
  before_action :configure_sign_up_params, only: [:create]

  protected

  # Cadastro mínimo (SMOKE + PRODUÇÃO SAFE)
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(
      :sign_up,
      keys: [:email, :password, :password_confirmation]
    )
  end

  # Redirecionamento seguro pós-cadastro
  def after_sign_up_path_for(resource)
    transportadores_dashboard_path
  end

  def after_inactive_sign_up_path_for(resource)
    transportadores_dashboard_path
  end
end
