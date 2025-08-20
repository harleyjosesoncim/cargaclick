# frozen_string_literal: true
class ApplicationController < ActionController::Base
  # Se quiser desabilitar a inferência automática de helpers, descomente:
  # self.helpers_path = []
  # frozen_string_literal: true
class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # Exija login de cliente por padrão, EXCETO páginas públicas e telas do Devise
  before_action :authenticate_cliente!, unless: :public_page?

  def after_sign_in_path_for(_resource)  = fretes_path
  def after_sign_up_path_for(_resource)  = fretes_path
  def after_sign_out_path_for(_resource) = unauthenticated_root_path

  private

  def public_page?
    return true if devise_controller?
    # Home pública e Clientes#index/show públicos enquanto depuramos
    (controller_name == 'home') ||
    (controller_name == 'clientes' && %w[index show].include?(action_name))
  end
end

end
