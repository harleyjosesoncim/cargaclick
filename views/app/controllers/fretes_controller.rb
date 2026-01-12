class FretesController < ApplicationController
  before_action :set_frete, only: [:show, :edit, :update, :destroy]
  before_action :authenticate_user!, except: [:index, :show]

  # GET /fretes
  def index
    @fretes = Frete.order(created_at: :desc).limit(50)
  end

  # GET /fretes/:id
  def show
    # @frete já definido em set_frete
  end

  # GET /fretes/new
  def new
    @frete = Frete.new
  end

  # POST /fretes
  def create
    @frete = Frete.new(frete_params)

    if @frete.save
      redirect_to @frete, notice: "Frete criado com sucesso."
    else
      flash.now[:alert] = "Erro ao criar frete."
      render :new, status: :unprocessable_entity
    end
  end

  # GET /fretes/:id/edit
  def edit
  end

  # PATCH/PUT /fretes/:id
  def update
    if @frete.update(frete_params)
      redirect_to @frete, notice: "Frete atualizado com sucesso."
    else
      flash.now[:alert] = "Erro ao atualizar frete."
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /fretes/:id
  def destroy
    @frete.destroy
    redirect_to fretes_path, notice: "Frete removido."
  end

  private

  # 🔒 Evita erro 500 por ID inválido
  def set_frete
    @frete = Frete.find_by(id: params[:id])
    unless @frete
      redirect_to fretes_path, alert: "Frete não encontrado."
    end
  end

  # 🔒 Strong Params (evita mass assignment e crashes)
  def frete_params
    params.require(:frete).permit(
      :origem,
      :destino,
      :distancia_km,
      :valor_total,
      :status,
      :cliente_id,
      :transportador_id
    )
  end
end
