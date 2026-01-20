# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  add_flash_types :success, :warning, :info

  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :authenticate_scope!, unless: :public_or_devise_page?

  # =========================================================
  # ROTAS PÚBLICAS (NÃO EXIGEM LOGIN)
  # =========================================================
  PUBLIC_ROUTES = [
    { controller: "landing",      actions: %w[index] },
    { controller: "home",         actions: %w[index about fidelidade] },
    { controller: "fretes",       actions: %w[new create] },
    { controller: "contatos",     actions: %w[new create] },
    { controller: "pagamentos",   actions: %w[webhook ping sucesso falha pendente retorno] },
    { controller: "rails/health", actions: %w[show] }
  ].freeze

  # =========================================================
  # Redirecionamento após login
  # =========================================================
  def after_sign_in_path_for(resource)
    case resource
    when AdminUser
      admin_root_path
    when Transportador
      transportadores_root_path
    when Cliente
      clientes_root_path
    else
      root_path
    end
  end

  protected

  # =========================================================
  # Devise - parâmetros extras
  # =========================================================
  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[nome telefone cpf])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[nome telefone cpf])
  end

  # =========================================================
  # Autenticação centralizada (1 único ponto)
  # =========================================================
  def authenticate_scope!
    return if respond_to?(:admin_signed_in?)         && admin_signed_in?
    return if respond_to?(:transportador_signed_in?) && transportador_signed_in?
    return if respond_to?(:cliente_signed_in?)       && cliente_signed_in?

    redirect_to root_path, alert: "Acesso não autorizado."
  end

  # =========================================================
  # Libera Devise + rotas públicas
  # =========================================================
  def public_or_devise_page?
    devise_controller? || public_page?
  end

  # =========================================================
  # Verifica se rota é pública
  # =========================================================
  def public_page?
    PUBLIC_ROUTES.any? do |route|
      route[:controller] == controller_path &&
        route[:actions].include?(action_name)
    end
  end
end
