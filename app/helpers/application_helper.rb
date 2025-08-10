module ApplicationHelper
  def active_link_class(path)
    current_page?(path) ? "underline decoration-2 decoration-blue-200 text-blue-100" : ""
  end

  # Opcional: Helper para verificar a página atual de forma mais simples se a rota não for exata
  def current_page?(path)
    request.path == path
  end
end