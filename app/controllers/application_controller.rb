# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  add_flash_types :success, :warning, :info

  # Autentica por padrão, exceto em páginas públicas
  before_action :authenticate_scope!, unless: :public_page?
  before_action :configure_permitted_parameters, if: :devise_controller?

  # --- Rotas públicas declarativas ---
  PUBLIC_ROUTES = [
    { controller: "landing",         actions: %w[index] },
    { controller: "home",            actions: %w[index about fidelidade] },
    { controller: "contatos",        actions: %w[new create] },
    { controller: "pagamentos",      actions: %w[webhook ping sucesso falha pendente retorno] },
    { controller: "rails/health",    actions: %w[show] }
  ].freeze

  # --- Redirecionamentos pós-auth (CORRIGIDO) ---
  def after_sign_in_path_for(resource)
    case resource
    when AdminUser
      admin_root_path
    when Transportador
      # Se você tiver uma dashboard para ele, use transportadores_root_path
      # Caso contrário, mande para a simulação de fretes
      simular_frete_path
    when Cliente
      # Redireciona para a simulação de frete após o login
      simular_frete_path
    else
      root_path
    end
  end

  def after_sign_up_path_for(resource)
    after_sign_in_path_for(resource)
  end

  def after_sign_out_path_for(_scope)
    # Garante que volta para a home sem erros
    root_path
  end

  private

  # --- Autenticação por escopo ---
  def authenticate_scope!
    # Evita loop infinito se já estiver no controller do Devise
    return if devise_controller?

    if admin_namespace?
      authenticate_admin_user!
    elsif transportador_namespace?
      authenticate_transportador!
    else
      # Se não for admin nem transportador, o padrão é cliente
      authenticate_cliente!
    end
  end

  def admin_namespace?
    controller_path.start_with?("admin/") || request.path.start_with?("/admin")
  end

  def transportador_namespace?
    controller_path.start_with?("transportadores/") || request.path.start_with?("/transportadores") || request.path.start_with?("/transportador")
  end

  # --- Páginas públicas ---
  def public_page?
    return true if devise_controller?

    PUBLIC_ROUTES.any? do |route|
      route[:controller] == controller_path &&
        (route[:actions].blank? || route[:actions].include?(action_name))
    end
  end

  # --- Devise strong params ---
  def configure_permitted_parameters
    extra_keys = case resource_name
                 when :transportador
                   %i[nome cpf cidade tipo_veiculo carga_maxima valor_km chave_pix mercado_pago_link tipo_documento documento cnh_numero placa_veiculo]
                 when :cliente
                   %i[nome telefone cidade]
                 else
                   []
                 end

    devise_parameter_sanitizer.permit(:sign_up, keys: extra_keys)
    devise_parameter_sanitizer.permit(:account_update, keys: extra_keys)
  end

  def default_url_options
    host = ENV["APP_HOST"].presence || "www.cargaclick.com.br"
    protocol = (request&.ssl? || ssl_forced?) ? "https" : "http"
    { host: host, protocol: protocol }
  end

  def ssl_forced?
    ActiveModel::Type::Boolean.new.cast(ENV.fetch("FORCE_SSL", Rails.env.production?))
  end
end