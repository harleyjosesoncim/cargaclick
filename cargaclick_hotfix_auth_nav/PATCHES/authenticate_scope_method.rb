# Substitua o seu método `authenticate_scope!` por este.
# Objetivo: não quebrar quando `authenticate_cliente!` não existir.
def authenticate_scope!
  return if devise_controller?

  # Se estiver logado como admin, valida o scope admin
  if respond_to?(:admin_signed_in?, true) && admin_signed_in?
    return authenticate_admin! if respond_to?(:authenticate_admin!, true)
  end

  # Se estiver logado como transportador, valida o scope transportador
  if respond_to?(:transportador_signed_in?, true) && transportador_signed_in?
    return authenticate_transportador! if respond_to?(:authenticate_transportador!, true)
  end

  # Se existir scope de cliente e estiver logado, valida
  if respond_to?(:cliente_signed_in?, true) && cliente_signed_in?
    return authenticate_cliente! if respond_to?(:authenticate_cliente!, true)
  end

  # Sem login: por padrão, deixa público (simulação/páginas).
  # Controllers que exigem cliente devem usar:
  #   before_action :authenticate_cliente!
  true
end
