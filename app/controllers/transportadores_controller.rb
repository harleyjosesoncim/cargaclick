class TransportadoresController < ApplicationController
  # Garante que a transportadora seja carregada antes de exibir, editar, atualizar ou excluir.
  before_action :set_transportador, only: [:show, :edit, :update, :destroy]

  # GET /transportadores
  # Exibe a lista de transportadoras, com opção de busca por cidade.
  def index
    if params[:cidade].present?
      # Busca transportadoras pela cidade (ignorando maiúsculas/minúsculas).
      @transportadores = Transportador.where('LOWER(cidade) LIKE ?', "%#{params[:cidade].downcase}%")
    else
      # Carrega todas as transportadoras se nenhuma cidade for especificada.
      @transportadores = Transportador.all
    end
  end

  # GET /transportadores/:id
  # Mostra os detalhes de uma transportadora específica.
  def show
    # A transportadora já foi carregada por `set_transportador`.
  end

  # GET /transportadores/new
  # Inicializa uma nova transportadora para o formulário de criação.
  def new
    @transportador = Transportador.new
    # Removido: @transportador.modal_transportadores.build
    # Não é mais necessário com o uso de `form.collection_check_boxes` e `modal_ids: []`
  end

  # GET /transportadores/:id/edit
  # Prepara o formulário para editar uma transportadora existente.
  def edit
    # Removido: @transportador.modal_transportadores.build if @transportador.modal_transportadores.empty?
    # Não é mais necessário com o uso de `form.collection_check_boxes` e `modal_ids: []`
  end

  # POST /transportadores
  # Cria uma nova transportadora com os dados submetidos.
  def create
    @transportador = Transportador.new(transportador_params)
    
    if params[:transportador][:modal_ids].blank?
      # Se nenhum modal for selecionado, adiciona um erro e re-renderiza o formulário.
      @transportador.errors.add(:modals, "deve ter pelo menos um modal de transporte selecionado.")
      render :new, status: :unprocessable_entity
      return
    end
    
    ActiveRecord::Base.transaction do
      @transportador.save!
      
      params[:transportador][:modal_ids].reject(&:blank?).map do |modal_id|
        ModalTransportador.create!(transportador_id: @transportador.id, modal_id: modal_id)
      end
    end

    redirect_to @transportador, notice: 'Transportador foi cadastrado com sucesso.'
  rescue ActiveRecord::RecordInvalid
    # Se a validação falhar, o @transportador terá os erros.
    # O formulário _form.html.erb irá re-renderizar e mostrar os erros e
    # manter os checkboxes selecionados corretamente.
    render :new, status: :unprocessable_entity
  end

  # PATCH/PUT /transportadores/:id
  # Atualiza uma transportadora existente com os dados submetidos.
  def update
    if @transportador.update(transportador_params)
      redirect_to @transportador, notice: 'Cadastro do Transportador foi atualizado com sucesso.'
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /transportadores/:id
  # Exclui uma transportadora do banco de dados.
  def destroy
    @transportador.destroy
    redirect_to transportadores_url, notice: "Transportadora excluída com sucesso!"
  end

  private

  # Método privado para carregar a transportadora com base no ID da URL.
  def set_transportador
    @transportador = Transportador.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    # Redireciona para a lista e exibe um alerta se a transportadora não for encontrada.
    redirect_to transportadores_url, alert: "Transportadora não encontrada."
  end

  # Método privado que define quais parâmetros são permitidos para criação e atualização.
  # Isso é uma medida de segurança para evitar atribuições em massa indesejadas.
  def transportador_params
    params.require(:transportador).permit(
      :nome,
      :cpf,
      :telefone,
      :endereco,
      :cep,
      :cidade,
      :carga_maxima
    )
  end
end
