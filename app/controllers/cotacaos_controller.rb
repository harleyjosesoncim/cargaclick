class CotacaosController < ApplicationController
  before_action :set_cotacao, only: %i[ show edit update destroy ]

  # GET /cotacaos
  def index
    @cotacaos = Cotacao.all
  end

  # GET /cotacaos/1
  def show
  end

  # GET /cotacaos/new
  def new
    @cotacao = Cotacao.new
  end

  # GET /cotacaos/1/edit
  def edit
  end

  # POST /cotacaos
  def create
    @cotacao = Cotacao.new(cotacao_params)

    if @cotacao.save
      redirect_to @cotacao, notice: "Cotacao was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /cotacaos/1
  def update
    if @cotacao.update(cotacao_params)
      redirect_to @cotacao, notice: "Cotacao was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /cotacaos/1
  def destroy
    @cotacao.destroy!
    redirect_to cotacaos_url, notice: "Cotacao was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_cotacao
      @cotacao = Cotacao.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def cotacao_params
      params.require(:cotacao).permit(:cliente_id, :origem, :destino, :peso, :volume, :status)
    end
end
