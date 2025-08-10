class PropostaController < ApplicationController
  before_action :set_propostum, only: %i[ show edit update destroy ]

  # GET /proposta
  def index
    @proposta = Proposta.all
  end

  # GET /proposta/1
  def show
  end

  # GET /proposta/new
  def new
    @propostum = Proposta.new
  end

  # GET /proposta/1/edit
  def edit
  end

  # POST /proposta
  def create
    @propostum = Proposta.new(propostum_params)

    if @propostum.save
      redirect_to @propostum, notice: "Proposta was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /proposta/1
  def update
    if @propostum.update(propostum_params)
      redirect_to @propostum, notice: "Proposta was successfully updated.", status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /proposta/1
  def destroy
    @propostum.destroy!
    redirect_to proposta_index_url, notice: "Proposta was successfully destroyed.", status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_propostum
      @propostum = Proposta.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def propostum_params
      params.require(:propostum).permit(:frete_id, :transportador_id, :valor_proposto, :observacao)
    end
end
