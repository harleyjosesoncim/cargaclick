class FretesController < ApplicationController
  before_action :set_frete, only: %i[show rastreamento entregar chat]

  # GET /fretes/new
  def new
    @frete = Frete.new
  end

  # POST /fretes
  def create
    @frete = Frete.new(frete_params)

    if @frete.save
      redirect_to @frete, notice: "Frete criado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /fretes/:id
  def show; end

  # GET /fretes/:id/rastreamento
  def rastreamento; end

  # POST /fretes/:id/entregar
  def entregar
    @frete.update(status: :entregue)
    redirect_to @frete, notice: "Frete marcado como entregue!"
  end

  # GET /fretes/:id/chat
  def chat; end

  private

  def set_frete
    @frete = Frete.find(params[:id])
  end

  def frete_params
    params.require(:frete).permit(:origem, :destino, :descricao, :peso, :largura, :altura, :profundidade)
  end
end
