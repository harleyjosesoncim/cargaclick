class TransportadoresController < ApplicationController
  def index
    @transportadores = Transportador.all
  end

  def new
    @transportador = Transportador.new
  end

  def create
    @transportador = Transportador.new(transportador_params)
    if @transportador.save
      redirect_to transportadores_path, notice: "Transportador cadastrado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @transportador = Transportador.find(params[:id])
  end

  def edit
    @transportador = Transportador.find(params[:id])
  end

  def update
    @transportador = Transportador.find(params[:id])
    if @transportador.update(transportador_params)
      redirect_to transportadores_path, notice: "Dados atualizados"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @transportador = Transportador.find(params[:id])
    @transportador.destroy
    redirect_to transportadores_path, notice: "Transportador removido com sucesso"
  end

  private

  def transportador_params
    params.require(:transportador).permit(
      :nome, :email, :telefone, :cpf, :cep, :tipo_veiculo,
      :carga_maxima, :valor_km, :largura, :altura, :profundidade,
      :peso_aproximado, :latitude, :longitude
    )
  end
end
