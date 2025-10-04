# app/helpers/navigation_helper.rb
module NavigationHelper
  # Retorna o destino do link "Início" conforme a sessão atual.
  # Ordem de prioridade:
  # 1) Cliente logado → authenticated_root_path (fretes#index)
  # 2) Transportador logado → página do transportador
  # 3) Visitante → unauthenticated_root_path (home#index)
  def home_link_path
    if defined?(cliente_signed_in?) && cliente_signed_in?
      authenticated_root_path
    elsif defined?(transportador_signed_in?) && transportador_signed_in?
      transportador_path(current_transportador)
    else
      unauthenticated_root_path
    end
  end

  # Retorna classes CSS para destacar link ativo.
  # Ex.: class: "link #{active_link_class(home_link_path)}"
  def active_link_class(path, active: "text-yellow-300", inactive: "")
    current_page?(path) ? active : inactive
    # Se preferir sempre adicionar e só alternar a cor, use:
    # "#{base_classes} #{current_page?(path) ? active : inactive}"
  end
end

