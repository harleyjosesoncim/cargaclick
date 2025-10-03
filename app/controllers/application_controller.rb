# frozen_string_literal: true

class ApplicationController < ActionController::Base
  # --- Segurança base ---
  protect_from_forgery with: :exception
  add_flash_types :success, :warning, :info

  # Force SSL somente em produção (opcional, mas recomendado)
  force_ssl if: :ssl_forced?

  # Autentica por padrão qualquer usuário válido, exceto páginas públicas
  before_action :authenticate_scope!, unless: :public_page?

  # Libera campos extras do Devise para cada recurso
  before_action :configure_permitted_parameters, if: :devise_controller?

  # Redirecionamentos pós-auth
  def after_sign_in_path_for(resource)
    case resource
    when AdminUser     then admin_root_path
    when Transportador then fretes_path          # ajuste se houver dashboard específico
    when Cliente       then fretes_path
    else                    super
    end
  end

  def after_sign_up_path_for(resource)
    after_sign_in_path_for(resource)
  end

  def after_sign_out_path_for(_resource_or_scope)
    unauthenticated_root_path
  end

  private

  # --- Autenticação por escopo (cliente/transportador/admin) ---
  def authenticate_scope!
    # Admin
    return authenticate_admin_user! if admin_namespace?

    # Controllers/rotas de transportadores
    if transportador_namespace?
      return authenticate_transportador!
    end

    # Padrão: exige cliente
    authenticate_cliente!
  end

  def admin_namespace?
    request.path.start_with?("/admin") || controller_path.start_with?("admin/")
  end

  def transportador_namespace?
    request.path.start_with?("/transportadores") || controller_path.start_with?("transportadores/")
  end

  # --- Páginas públicas (sem login) ---
  def public_page?
    return true if devise_controller?
    return true if params[:controller] == "rails/health" # /up

    PUBLIC_ROUTES.any? do |r|
      r[:controller] == controller_path && (r[:actions].blank? || r[:actions].include?(action_name))
    end
  end

  # Defina aqui o que é público
  PUBLIC_ROUTES = [
    { controller: "home",          actions: %w[index about fidelidade] },
    { controller: "contatos",      actions: %w[new create] },
    { controller: "pagamentos",    actions: %w[webhook ping sucesso falha pendente retorno] },
    # se tiver páginas públicas adicionais, adicione aqui
  ].freeze

  # --- Devise strong params por recurso ---
  def configure_permitted_parameters
    extra_keys =
      case resource_name
      when :transportador
        %i[
          nome cpf cidade tipo_veiculo carga_maxima valor_km
          chave_pix mercado_pago_link
        ]
      when :cliente
        %i[nome telefone cidade]
      else
        []
      end

    devise_parameter_sanitizer.permit(:sign_up,        keys: extra_keys)
    devise_parameter_sanitizer.permit(:account_update, keys: extra_keys)
  end

  # --- Utilidades ---
  def ssl_forced?
    Rails.env.production? && ActiveModel::Type::Boolean.new.cast(ENV.fetch("FORCE_SSL", true))
  end

  # URLs absolutas corretas em mailers/links (opcional, mas útil)
  def default_url_options
    host = ENV["APP_HOST"].presence
    host ? { host:, protocol: (request&.ssl? || ssl_forced?) ? "https" : "http" } : {}
  end
end

