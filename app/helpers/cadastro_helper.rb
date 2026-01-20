module CadastroHelper
  def percentual_cadastro(usuario)
    case usuario.status_cadastro
    when "basico"    then 40
    when "completo"  then 100
    else 0
    end
  end

  def texto_status_cadastro(usuario)
    case usuario.status_cadastro
    when "basico"   then "Cadastro básico"
    when "completo" then "Cadastro completo"
    else "Cadastro incompleto"
    end
  end
end
