# app/helpers/cliente_navigation_helper.rb
module ClienteNavigationHelper
  def cliente_autenticado?
    respond_to?(:cliente_signed_in?) && cliente_signed_in?
  rescue
    false
  end

  def cliente_home_path
    if cliente_autenticado? && respond_to?(:authenticated_root_path)
      authenticated_root_path
    else
      root_path
    end
  end

  def cliente_links
    return [] unless cliente_autenticado?

    [
      { label: "Meus Fretes", path: authenticated_root_path },
      { label: "Perfil", path: "/cliente" }
    ]
  end
end
