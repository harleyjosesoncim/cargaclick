class FretesController < ApplicationController
  before_action :set_frete, only: %i[show edit update destroy chat rastreamento]

  def new
    @frete = Frete.new
  end

  def create
    @frete = Frete.new(frete_params)

    # offline-safe: não chama APIs externas automaticamente
    @frete.valor ||= @frete.calcular_valor if @frete.respond_to?(:calcular_valor)

    if @frete.save
      redirect_to @frete, notice: "Frete criado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show; end
  def edit; end

  def update
    if @frete.update(frete_params)
      redirect_to @frete, notice: "Frete atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @frete.destroy
    redirect_to inicio_path, notice: "Frete removido."
  end

  def chat; end

  def rastreamento
    # offline-safe: a view entra em fallback sem Leaflet/CDN
  end

  private

  def set_frete
    @frete = Frete.find(params[:id])
  end

  def frete_params
    params.require(:frete).permit(
      :origem, :destino, :peso, :volume, :tipo_carga, :tipo_veiculo,
      :descricao, :valor, :status
    )
  end
end
