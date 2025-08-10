class Transportadores::RegistrationsController < Devise::RegistrationsController
  layout 'application'

  protected

  # Redirecionar para a tela de sucesso após cadastro
  def after_sign_up_path_for(resource)
    sucesso_cadastro_path  # Usando a mesma tela de sucesso dos clientes
  end

  # Caso queira adicionar campos extras no cadastro (ex: nome, tipo_veiculo, cnpj, etc.)
  def configure_sign_up_params
    devise_parameter_sanitizer.permit(:sign_up, keys: [:nome, :tipo_veiculo, :cnpj])
  end
end
