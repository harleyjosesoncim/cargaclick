class TransportadoresController < ApplicationController
  before_action :set_transportador, only: [:show, :edit, :update, :destroy]

  # GET /transportadores
  def index
    if params[:cidade].present?
      @transportadores = Transportador.where('LOWER(cidade) LIKE ?', "%#{params[:cidade].downcase}%")
    else
      @transportadores = Transportador.all
    end
  end

  # GET /transportadores/:id
  def show; end

  # GET /transportadores/new
  def new
    @transportador = Transportador.new
  end

  # GET /transportadores/:id/edit
  def edit; end

  # POST /transportadores
  def create
    @transportador = Transportador.new(transportador_params)

    if params[:transportador][:modal_ids].blank?
      @transportador.errors.add(:modals, "deve ter pelo menos um modal de transporte selecionado.")
      render :new, status: :unprocessable_entity
      return
    end

    ActiveRecord::Base.transaction do
      @transportador.save!
      params[:transportador][:modal_ids].reject(&:blank?).each do |modal_id|
        ModalTransportador.create!(transportador_id: @transportador.id, modal_id: modal_id)
      end
    end

    redirect_to @transportador, notice: 'Transportador foi cadastrado com sucesso.'
  rescue ActiveRecord::RecordInvalid
    render :new, status: :unprocessable_entity
  end

  # GET /cadastro/transportador
  def cadastro_publico
    @transportador = Transportador.new
  end

  # POST /cadastro/transportador
  def criar_publico
    @transportador = Transportador.new(public_transportador_params)
    if @transportador.save
      redirect_to root_path, notice: "Cadastro realizado com sucesso! Em breve você receberá solicitações de frete."
    else
      render :cadastro_publico
    end
  end

  # PATCH/PUT /transportadores/:id
  def update
    if @transportador.update(transportador_params)
      redirect_to @transportador, notice: 'Cadastro do Transportador foi atualizado com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /transportadores/:id
  def destroy
    @transportador.destroy
    redirect_to transportadores_url, notice: "Transportadora excluída com sucesso!"
  end

  private

  def set_transportador
    @transportador = Transportador.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to transportadores_url, alert: "Transportadora não encontrada."
  end

  def transportador_params
    params.require(:transportador).permit(
      :nome, :cpf, :telefone, :endereco, :cep, :cidade, :carga_maxima, modal_ids: []
    )
  end

  def public_transportador_params
    params.require(:transportador).permit(:nome, :cpf, :tipo_veiculo, :email)
  end
end