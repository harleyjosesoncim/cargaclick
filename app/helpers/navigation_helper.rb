# app/helpers/navigation_helper.rb
module NavigationHelper
  # =====================================================
  # LINK PRINCIPAL ("INÍCIO")
  # =====================================================
  #
  # GARANTIAS:
  # - Nunca chama métodos inexistentes
  # - Nunca chama rotas inexistentes
  # - Nunca usa send
  # - Não assume Devise
  # - Fallback absoluto garantido
  #
  def home_link_path
    cliente_area_path ||
      transportador_area_path ||
      root_path
  rescue StandardError
    root_path
  end

  # =====================================================
  # LINK ATIVO
  # =====================================================
  def active_link_class(path, active: "text-yellow-300", inactive: "")
    current_page?(path) ? active : inactive
  rescue StandardError
    inactive
  end

  private

  # =====================================================
  # CONTEXTO: CLIENTE
  # =====================================================

  def cliente_area_path
    return unless cliente_logado?
    return unless route_exists?(:cliente_path)
    return unless respond_to?(:current_cliente)

    cliente = current_cliente
    return unless cliente&.id

    cliente_path(cliente)
  rescue StandardError
    nil
  end

  def cliente_logado?
    respond_to?(:cliente_signed_in?) && cliente_signed_in?
  rescue StandardError
    false
  end

  # =====================================================
  # CONTEXTO: TRANSPORTADOR
  # =====================================================

  def transportador_area_path
    return unless transportador_logado?
    return unless route_exists?(:transportador_path)
    return unless respond_to?(:current_transportador)

    transportador = current_transportador
    return unless transportador&.id

    transportador_path(transportador)
  rescue StandardError
    nil
  end

  def transportador_logado?
    respond_to?(:transportador_signed_in?) && transportador_signed_in?
  rescue StandardError
    false
  end

  # =====================================================
  # SEGURANÇA
  # =====================================================

  def route_exists?(route_helper)
    Rails.application.routes.url_helpers.respond_to?(route_helper)
  end
end
