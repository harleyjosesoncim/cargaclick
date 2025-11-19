# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # --- Segurança base ---
  protect_from_forgery with: :exception
  add_flash_types :success, :warning, :info

  # (NÃO use force_ssl aqui; faça isso em config/environments/production.rb)

  # Autentica por padrão qualquer usuário válido, exceto páginas públicas
  before_action :authenticate_scope!, unless: :public_page?

  # Libera campos extras do Devise para cada recurso
  before_action :configure_permitted_parameters, if: :devise_controller?

  # --- Rotas públicas declarativas ---
  PUBLIC_ROUTES = [
    # Landing / página inicial pública
    { controller: "landing",        actions: %w[index] },

    # Páginas institucionais
    { controller: "home",           actions: %w[index about fidelidade] },

    # Contato público
    { controller: "contatos",       actions: %w[new create] },

    # Webhooks e retornos de pagamento (não exigem login)
    { controller: "pagamentos",     actions: %w[webhook ping sucesso falha pendente retorno] },

    # Healthcheck /up
    { controller: "rails/health",   actions: %w[show] }
  ].freeze

  # --- Redirecionamentos pós-auth ---
  def after_sign_in_path_for(resource)
    case resource
    when AdminUser
      admin_root_path
    when Transportador
      fretes_path
    when Cliente
      fretes_path
    else
      super
    end
  end

  def after_sign_up_path_for(resource)
    after_sign_in_path_for(resource)
  end

  def after_sign_out_path_for(_scope)
    unauthenticated_root_path
  end

  private

  # --- Autenticação por escopo (cliente/transportador/admin) ---
  def authenticate_scope!
    if admin_namespace?
      authenticate_admin_user!
    elsif transportador_namespace?
      authenticate_transportador!
    else
      authenticate_cliente!
    end
  end

  def admin_namespace?
    controller_path.start_with?("admin/") || request.path.start_with?("/admin")
  end

  def transportador_namespace?
    controller_path.start_with?("transportadores/") || request.path.start_with?("/transportadores")
  end

  # --- Páginas públicas (sem login) ---
  def public_page?
    # Devise cuida da própria proteção (ex: edit de conta), então deixamos ele decidir
    return true if devise_controller?

    PUBLIC_ROUTES.any? do |route|
      route[:controller] == controller_path &&
        (route[:actions].blank? || route[:actions].include?(action_name))
    end
  end

  # --- Devise strong params por recurso ---
  def configure_permitted_parameters
    extra_keys =
      case resource_name
      when :transportador
        %i[nome cpf cidade tipo_veiculo carga_maxima valor_km chave_pix mercado_pago_link]
      when :cliente
        %i[nome telefone cidade]
      else
        []
      end

    devise_parameter_sanitizer.permit(:sign_up,        keys: extra_keys)
    devise_parameter_sanitizer.permit(:account_update, keys: extra_keys)
  end

  # --- URLs absolutas em links/mails (usa APP_HOST se definido) ---
  def default_url_options
    host = ENV["APP_HOST"].presence
    return {} unless host

    protocol = (request&.ssl? || ssl_forced?) ? "https" : "http"
    { host: host, protocol: protocol }
  end

  # Decide protocolo quando precisamos montar URL absoluta
  def ssl_forced?
    ActiveModel::Type::Boolean.new.cast(
      ENV.fetch("FORCE_SSL", Rails.env.production?)
    )
  end
end
