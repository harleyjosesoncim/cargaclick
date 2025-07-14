class FretesController < ApplicationController
  def calcular
    @frete = Frete.new
  end

  def create
    @frete = Frete.new(frete_params)
    if @frete.save
      flash[:notice] = "Frete criado com sucesso!"
      redirect_to fretes_path
    else
      flash.now[:alert] = "Erro ao criar frete."
      render :calcular
    end
  end

  def calcular_frete
    transportador = Transportador.find(params[:transportador_id])
    peso = params[:peso].to_f
    distancia = params[:distancia].to_f

    taxa_por_kg = 0.05
    valor = (distancia * transportador.valor_km) + (peso * taxa_por_kg)

    # Valor médio estimado de mercado
    valor_medio_mercado = estimativa_mercado(distancia, peso)

    render json: {
      valor_estimado: valor.round(2),
      valor_mercado: valor_medio_mercado.round(2)
    }
  end

  private

  def frete_params
    params.require(:frete).permit(
      :volume, :ponto_referencia, :horario_entrega, :previsao_chegada,
      :previsao_km, :aceite_responsabilidade, :localizacao_lat, :localizacao_lng
    )
  end

  def estimativa_mercado(distancia, peso)
    media_por_km = 2.70   # Base ANTT ou mercado
    media_por_kg = 0.06   # Média prática de mercado

    (distancia * media_por_km) + (peso * media_por_kg)
  end
end
