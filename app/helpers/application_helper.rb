module ApplicationHelper
  def current_cliente
    # Simula cliente logado (ajuste conforme seu Devise)
    session[:tipo_usuario] == 'cliente'
  end

  def current_transportador
    session[:tipo_usuario] == 'transportador'
  end
end
