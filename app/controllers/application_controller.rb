# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  add_flash_types :success, :warning, :info

  before_action :authenticate_scope!, unless: :public_page?
  before_action :configure_permitted_parameters, if: :devise_controller?

  # =========================================================
  # ROTAS PÚBLICAS (NÃO EXIGEM LOGIN)
  # =========================================================
  PUBLIC_ROUTES = [
    { controller: "landing",      actions: %w[index] },
    { controller: "home",         actions: %w[index about fidelidade] },
    { controller: "fretes",       actions: %w[new create] }, # simulação pública
    { controller: "contatos",     actions: %w[new create] },
    { controller: "pagamentos",   actions: %w[webhook ping sucesso falha pendente retorno] },
    { controller: "rails/health", actions: %w[show] }
  ].freeze

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

  protected

  def authenticate_scope!
    return if devise_controller?

    if respond_to?(:admin_signed_in?, true) && admin_signed_in?
      return authenticate_admin! if respond_to?(:authenticate_admin!, true)
    end

    if respond_to?(:transportador_signed_in?, true) && transportador_signed_in?
      return authenticate_transportador! if respond_to?(:authenticate_transportador!, true)
    end

    if respond_to?(:cliente_signed_in?, true) && cliente_signed_in?
      return authenticate_cliente! if respond_to?(:authenticate_cliente!, true)
    end

    true
  end

  def public_page?
    PUBLIC_ROUTES.any? do |route|
      route[:controller] == controller_path &&
        route[:actions].include?(action_name)
    end
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[nome telefone cpf role])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[nome telefone cpf role])
  end
end
