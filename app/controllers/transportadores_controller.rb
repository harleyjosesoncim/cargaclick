class TransportadoresController < ApplicationController
  before_action :set_transportador, only: [:show, :edit, :update, :destroy]

  # GET /transportadores
  def index
    @transportadores =
      if params[:cidade].present?
        termo = params[:cidade].to_s.downcase.strip
        Transportador.where('LOWER(cidade) LIKE ?', "%#{termo}%")
      else
        Transportador.all
      end

    @transportadores = @transportadores.order(created_at: :desc)
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
    modal_ids = parsed_modal_ids

    if modal_ids.empty?
      @transportador.errors.add(:modals, 'deve ter pelo menos um modal de transporte selecionado.')
      render :new, status: :unprocessable_entity and return
    end

    ActiveRecord::Base.transaction do
      @transportador.save!
      sync_modal_transportadores!(@transportador, modal_ids)
    end

    redirect_to @transportador, notice: 'Transportador foi cadastrado com sucesso.'
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.warn("[Transportadores#create] erro: #{e.message}")
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
      redirect_to root_path, notice: 'Cadastro realizado com sucesso! Em breve você receberá solicitações de frete.'
    else
      render :cadastro_publico, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /transportadores/:id
  def update
    modal_ids = parsed_modal_ids

    if modal_ids.empty?
      @transportador.errors.add(:modals, 'deve ter pelo menos um modal de transporte selecionado.')
      render :edit, status: :unprocessable_entity and return
    end

    ActiveRecord::Base.transaction do
      @transportador.update!(transportador_params)
      sync_modal_transportadores!(@transportador, modal_ids)
    end

    redirect_to @transportador, notice: 'Cadastro do Transportador foi atualizado com sucesso.'
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.warn("[Transportadores#update] erro: #{e.message}")
    render :edit, status: :unprocessable_entity
  end

  # DELETE /transportadores/:id
  def destroy
    @transportador.destroy
    redirect_to transportadores_url, notice: 'Transportadora excluída com sucesso!'
  rescue ActiveRecord::InvalidForeignKey => e
    Rails.logger.error("[Transportadores#destroy] FK error: #{e.message}")
    redirect_to transportadores_url, alert: 'Não foi possível excluir: há registros relacionados.'
  end

  private

  def set_transportador
    @transportador = Transportador.find_by(id: params[:id])
    return if @transportador.present?

    redirect_to transportadores_url, alert: 'Transportadora não encontrada.'
  end

  # strong params (inclui :email e campos de veículo)
  def transportador_params
    params.require(:transportador).permit(
      :nome, :cpf, :telefone, :endereco, :cep, :cidade,
      :tipo_veiculo, :carga_maxima, :valor_km, :altura,
      :profundidade, :peso_aproximado, :fidelidade_pontos,
      :email, modal_ids: [] # modal_ids vem do form (checkboxes)
    )
  end

  # cadastro público com os campos essenciais
  def public_transportador_params
    params.require(:transportador).permit(:nome, :cpf, :tipo_veiculo, :email, :cidade, :telefone, :cep)
  end

  # normaliza e garante array único de IDs
  def parsed_modal_ids
    Array(params.dig(:transportador, :modal_ids))
      .reject(&:blank?)
      .map(&:to_i)
      .uniq
  end

  # sincroniza a tabela de junção ModalTransportador de forma idempotente
  def sync_modal_transportadores!(transportador, modal_ids)
    # remove os que não estão mais selecionados
    transportador.modal_transportadores.where.not(modal_id: modal_ids).delete_all

    # cria os que faltam
    existentes = transportador.modal_transportadores.pluck(:modal_id)
    (modal_ids - existentes).each do |mid|
      transportador.modal_transportadores.create!(modal_id: mid)
    end
  end
end
