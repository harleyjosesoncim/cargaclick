# app/controllers/application_controller.rb
# frozen_string_literal: true

class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  # Tipos de flash extras (úteis com Tailwind)
  add_flash_types :info, :success, :warning, :error

  # Usa layout minimalista nas telas do Devise (evita 500 por partials/menus)
  layout :layout_by_resource

  # Callbacks globais
  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :store_user_location!, if: :storable_location?

  # ---------------------------
  # Redirecionamentos do Devise
  # ---------------------------

  # Depois de LOGIN
  def after_sign_in_path_for(resource)
    path = stored_location_for(resource)
    return path if safe_redirect_path?(path)
    redirect_path_for(resource)
  end

  # Depois de SIGN UP
  def after_sign_up_path_for(resource)
    redirect_path_for(resource)
  end

  # Depois de LOGOUT
  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end

  # ---------------------------
  # Helpers gerais
  # ---------------------------

  helper_method :current_domain
  def current_domain
    request.base_url
  end

  # Inclui locale nas URLs (apenas se não for o default)
  def default_url_options
    I18n.locale == I18n.default_locale ? {} : { locale: I18n.locale }
  end

  # ---------------------------
  # Tratamento de exceções comuns
  # ---------------------------

  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from ActionController::InvalidAuthenticityToken, with: :handle_bad_csrf

  if defined?(Pundit)
    include Pundit::Authorization
    rescue_from Pundit::NotAuthorizedError, with: :render_403
  end

  # Enriquecer logs (útil em PaaS/containers)
  def append_info_to_payload(payload)
    super
    payload[:request_id] = request.request_id
    payload[:remote_ip]  = request.remote_ip
    payload[:user_scope] = current_devise_scope
    payload[:user_id]    = current_any_user_id
  end

  private

  # Escolhe layout minimalista para Devise
  def layout_by_resource
    devise_controller? ? "devise" : "application"
  end

  # Para onde mandar cada tipo de usuário
  def redirect_path_for(resource)
    if respond_to?(:admin_root_path) &&
       resource.respond_to?(:admin?) && resource.admin?
      admin_root_path
    elsif respond_to?(:dashboard_transportador_path) &&
          resource.class.name.to_s.include?("Transportador")
      dashboard_transportador_path
    elsif respond_to?(:fretes_path)
      fretes_path
    else
      root_path
    end
  end

  # Evita redirecionar para páginas de autenticação/external
  def safe_redirect_path?(path)
    return false if path.blank?
    return false if path.match?(%r{/(sign_in|sign_out|sign_up)\b})
    # impede open redirect: só permite caminhos internos ("/algo")
    return false if path.start_with?("http://", "https://")
    true
  end

  # Locale com whitelisting + fallback ao Accept-Language
  def set_locale
    param_locale   = params[:locale].presence
    header_locale  = extract_locale_from_accept_language_header
    available      = I18n.available_locales.map(&:to_s)

    chosen = [param_locale, header_locale, I18n.default_locale].find do |loc|
      loc.present? && available.include?(loc.to_s)
    end

    I18n.locale = chosen || I18n.default_locale
  end

  def extract_locale_from_accept_language_header
    lang = request.env["HTTP_ACCEPT_LANGUAGE"].to_s.split(",").first
    lang&.slice(0, 5) # ex.: "pt-BR", "en-US", "pt"
  end

  # Strong params do Devise – ajuste conforme seus campos
  def configure_permitted_parameters
    base_keys = %i[nome name cpf cnpj telefone celular cidade estado cep avatar]
    devise_parameter_sanitizer.permit(:sign_up,        keys: base_keys)
    devise_parameter_sanitizer.permit(:account_update, keys: base_keys + %i[password password_confirmation current_password])
  end

  # Guardar URL alvo para voltar após login (apenas GET navegável)
  def storable_location?
    request.get? &&
      is_navigational_format? &&
      !devise_controller? &&
      !(request.respond_to?(:xhr?) && request.xhr?) &&
      !request.path.match?(%r{/(sign_in|sign_out|sign_up)\b})
  end

  # Salva para todos os escopos do Devise (evita “perder” destino)
  def store_user_location!
    if defined?(Devise)
      Devise.mappings.keys.each { |scope| store_location_for(scope, request.fullpath) }
    end
  end

  # ----- Renderizadores de erro -----

  def render_404
    path = Rails.root.join("public/404.html")
    if File.exist?(path)
      render file: path, status: :not_found, layout: false
    else
      head :not_found
    end
  end

  def render_403
    path = Rails.root.join("public/403.html")
    if File.exist?(path)
      render file: path, status: :forbidden, layout: false
    else
      head :forbidden
    end
  end

  def handle_bad_csrf
    reset_session
    redirect_to default_sign_in_path, alert: "Sua sessão expirou. Faça login novamente."
  end

  def default_sign_in_path
    if defined?(Devise)
      Devise.mappings.keys.each do |scope|
        helper = "new_#{scope}_session_path"
        return send(helper) if respond_to?(helper)
      end
    end
    root_path
  end

  # ----- Helpers de logging -----

  def current_devise_scope
    return nil unless defined?(Devise)
    Devise.mappings.keys.find { |scope| send("#{scope}_signed_in?") rescue false }
  end

  def current_any_user_id
    return nil unless defined?(Devise)
    Devise.mappings.keys.each do |scope|
      obj = send("current_#{scope}") rescue nil
      return obj.id if obj&.respond_to?(:id)
    end
    nil
  end
end
