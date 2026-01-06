# app/helpers/transportador_navigation_helper.rb
module TransportadorNavigationHelper
  def transportador_autenticado?
    respond_to?(:transportador_signed_in?) && transportador_signed_in?
  rescue
    false
  end

  def transportador_home_path
    if transportador_autenticado? &&
       respond_to?(:transportador_path) &&
       current_transportador.present?
      transportador_path(current_transportador)
    else
      root_path
    end
  end

  def transportador_links
    return [] unless transportador_autenticado?

    [
      { label: "Painel", path: transportador_home_path },
      { label: "Solicitações", path: "/transportador/solicitacoes" }
    ]
  end
end
