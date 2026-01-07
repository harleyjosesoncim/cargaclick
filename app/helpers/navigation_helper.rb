# app/helpers/navigation_helper.rb
# Helper central para evitar "pontas soltas" (helpers de rota inexistentes)
# e padronizar navegação (mobile-first).

module NavigationHelper
  # Retorna o primeiro helper de rota disponível.
  # Ex.: nav_path(:root_path, :home_path, fallback: "/")
  def nav_path(*helpers, fallback: "/")
    helpers.flatten.compact.each do |h|
      next unless h.is_a?(Symbol)
      next unless respond_to?(h)
      return public_send(h)
    end
    fallback
  rescue StandardError
    fallback
  end

  # true se o helper de rota existe no contexto atual (views/helpers)
  def route_exists?(helper_sym)
    helper_sym.is_a?(Symbol) && respond_to?(helper_sym)
  rescue StandardError
    false
  end

  # Classe de item ativo (para menu/navbar/footer)
  def nav_active_class(target_path)
    return "" if target_path.blank?

    current = request.path.to_s
    target  = target_path.to_s

    return "text-yellow-300" if current == target
    return "text-yellow-300" if target != "/" && current.start_with?(target)

    ""
  rescue StandardError
    ""
  end
end
