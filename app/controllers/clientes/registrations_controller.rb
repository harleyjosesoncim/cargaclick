class Clientes::RegistrationsController < Devise::RegistrationsController
  rescue_from ActiveRecord::RecordInvalid, with: :falha_controlada
  rescue_from StandardError, with: :falha_controlada

  protected

  def after_sign_up_path_for(_resource)
    root_path
  end

  private

  def falha_controlada(error)
    Rails.logger.error "[CLIENTE SIGNUP] #{error.class}: #{error.message}"
    redirect_to new_cliente_registration_path,
      alert: "Erro ao criar cadastro. Informe apenas e-mail e senha."
  end
end
