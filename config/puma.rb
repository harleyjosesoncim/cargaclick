# frozen_string_literal: true

require "uri"

class ApplicationController < ActionController::Base
  # Proteção contra CSRF com fallback para resetar sessão
  protect_from_forgery with: :exception, prepend: true

  # Tipos de flash adicionais para uso com Tailwind
  add_flash_types :info, :success, :warning, :error

  # Usa layout específico para telas do Devise
  layout :layout_by_resource

  # Callbacks globais
  before_action :set_locale
  before_action :configure_permitted_parameters, if: :devise_controller?
  before_action :store_user_location!, if: :storable_location?

  # Tratamento de exceções comuns
  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from ActionController::InvalidAuthenticityToken, with: :handle_bad_csrf

  # Suporte a Pundit, se presente
  if defined?(Pundit)
    include Pundit::Authorization
    rescue_from Pundit::NotAuthorizedError, with: :render_403
  end

  # Enriquecer logs para monitoramento em produção
  def append_info_to_payload(payload)
    super
    payload[:request_id] = request.request_id
    payload[:remote_ip] = request.remote_ip
    payload[:user_scope] = current_devise_scope
    payload[:user_id] = current_any_user_id
    payload[:user_agent] = request.user_agent
  end

  private

  # Define layout baseado no controlador (Devise ou padrão)
  def layout_by_resource
    devise_controller? ? "devise" : "application"
  end

  # Redirecionamento após login
  def after_sign_in_path_for(resource)
    path = stored_location_for(resource)
    safe_redirect_path?(path) ? path : redirect_path_for(resource)
  end

  # Redirecionamento após cadastro
  def after_sign_up_path_for(resource)
    redirect_path_for(resource)
  end

  # Redirecionamento após logout
  def after_sign_out_path_for(_resource_or_scope)
    root_path
  end

  # Determina o caminho de redirecionamento com base no tipo de usuário
  def redirect_path_for(resource)
    return admin_root_path if defined?(admin_root_path) && resource.respond_to?(:admin?) && resource.admin?
    return dashboard_transportador_path if defined?(dashboard_transportador_path) && resource.class.name.to_s.include?("Transportador")
    return fretes_path if respond_to?(:fretes_path)
    root_path
  end

  # Valida caminhos de redirecionamento para segurança
  def safe_redirect_path?(path)
    return false unless path.is_a?(String) && path.present? && path.bytesize <= 2048
    return false if path.include?("\n") || path.include?("\r")
    return false if path.match?(%r{\A/(sign_in|sign_out|sign_up)\b}i)
    return false if path.start_with?("http://", "https://", "javascript:")

    begin
      uri = URI.parse(path)
      uri.host.nil? && path.start_with?("/")
    rescue URI::InvalidURIError
      false
    end
  end

  # Configura locale com base em parâmetros, cabeçalho ou padrão
  def set_locale
    available = I18n.available_locales.map(&:to_s)
    param_locale = params[:locale].to_s.presence
    header_locale = extract_locale_from_accept_language_header

    I18n.locale = [param_locale, header_locale, I18n.default_locale.to_s].find do |loc|
      loc.present? && available.include?(loc.to_s)
    end || I18n.default_locale
  end

  # Extrai locale do cabeçalho HTTP Accept-Language
  def extract_locale_from_accept_language_header
    request.env["HTTP_ACCEPT_LANGUAGE"].to_s.split(",").first&.strip
  end

  # Configura parâmetros permitidos para Devise
  def configure_permitted_parameters
    base_keys = %i[nome name cpf cnpj telefone celular cidade estado cep avatar]
    devise_parameter_sanitizer.permit(:sign_up, keys: base_keys)
    devise_parameter_sanitizer.permit(:account_update, keys: base_keys + %i[password password_confirmation current_password])
  end

  # Verifica se a URL pode ser armazenada para redirecionamento
  def storable_location?
    request.get? &&
      is_navigational_format? &&
      !devise_controller? &&
      !request.xhr? &&
      !request.path.match?(%r{/(sign_in|sign_out|sign_up)\b}i)
  end

  # Armazena a localização do usuário para todos os escopos do Devise
  def store_user_location!
    return unless defined?(Devise)
    Devise.mappings.keys.each { |scope| store_location_for(scope, request.fullpath) }
  end

  # Renderiza erro 404
  def render_404
    path = Rails.root.join("public/404.html")
    File.exist?(path) ? render(file: path, status: :not_found, layout: false) : head(:not_found)
  end

  # Renderiza erro 403
  def render_403
    path = Rails.root.join("public/403.html")
    File.exist?(path) ? render(file: path, status: :forbidden, layout: false) : head(:forbidden)
  end

  # Trata falhas de CSRF
  def handle_bad_csrf
    reset_session
    redirect_to default_sign_in_path, alert: I18n.t("devise.failure.session_expired")
  end

  # Determina o caminho padrão de login
  def default_sign_in_path
    return root_path unless defined?(Devise)
    Devise.mappings.keys.each do |scope|
      helper = "new_#{scope}_session_path"
      return send(helper) if respond_to?(helper, true)
    end
    root_path
  end

  # Determina o escopo ativo do Devise para logs
  def current_devise_scope
    return unless defined?(Devise)
    Devise.mappings.keys.find { |scope| send("#{scope}_signed_in?") rescue false }
  end

  # Obtém o ID do usuário autenticado para logs
  def current_any_user_id
    return unless defined?(Devise)
    Devise.mappings.keys.each do |scope|
      obj = send("current_#{scope}") rescue nil
      return obj.id if obj&.respond_to?(:id)
    end
    nil
  end

  # Helper para obter o domínio atual
  helper_method :current_domain
  def current_domain
    request.base_url
  end

  # Inclui locale nas URLs, exceto para o locale padrão
  def default_url_options
    I18n.locale == I18n.default_locale ? {} : { locale: I18n.locale }
  end
end