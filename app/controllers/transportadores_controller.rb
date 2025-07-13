class TransportadoresController < ApplicationController
  def new
    @transportador = Transportador.new
  end

  # Outros métodos (index, create, etc) podem ficar aqui normalmente

  private
  def transportador_params
    params.require(:transportador).permit(
      :nome, :cpf, :telefone, :endereco, :cep, :tipo_veiculo, :carga_maxima, :valor_km,
      :largura, :altura, :profundidade, :peso_aproximado
    )
  end
end
