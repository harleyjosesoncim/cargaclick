# app/helpers/navigation_helper.rb
module NavigationHelper
  # Escolhe o destino do "Home" conforme sessão
  def home_link_path
    if defined?(cliente_signed_in?) && cliente_signed_in?
      authenticated_root_path   # /  → fretes#index (cliente logado)
    else
      unauthenticated_root_path # /  → home#index  (visitante)
    end
  end
end
