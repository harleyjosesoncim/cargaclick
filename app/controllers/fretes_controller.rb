class FretesController < ApplicationController
  before_action :authenticate_cliente!  # <-- Verifica se está logado
  before_action :set_frete, only: %i[show rastreamento entregar chat]
  before_action :authorize_cliente!, only: %i[show rastreamento entregar chat]

  # GET /fretes
  def index
    @fretes = current_cliente.fretes.order(created_at: :desc)
  end

  # GET /fretes/new
  def new
    @frete = Frete.new
  end

  # POST /fretes
  def create
    @frete = Frete.new(frete_params)
    @frete.cliente = current_cliente  # <-- Associação com cliente logado

    if @frete.save
      redirect_to @frete, notice: "Frete criado com sucesso!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /fretes/:id
  def show
  end

  # GET /fretes/:id/rastreamento
  def rastreamento
    # Lógica de rastreamento (view e serviço)
  end

  # POST /fretes/:id/entregar
  def entregar
    if @frete.update(status: :entregue)
      redirect_to @frete, notice: "Frete marcado como entregue!"
    else
      redirect_to @frete, alert: "Erro ao marcar como entregue."
    end
  end
  def gerar_proposta
  frete = Frete.find(params[:id])
  prompt = "Gere uma proposta comercial para o frete de #{frete.origem} até #{frete.destino}, peso: #{frete.peso}kg."

  proposta = OpenaiService.new(prompt).call  # OpenaiService já configurado para pegar ENV['OPENAI_API_KEY']

  render json: { proposta: proposta }
end

  # GET /fretes/:id/chat
  def chat
    # Lógica do chat (ActionCable, API, etc.)
  end

  private

    def authenticate_cliente!
      unless current_cliente
        redirect_to new_cliente_session_path, alert: "Você precisa estar logado para continuar."
      end
    end

    def set_frete
      @frete = Frete.find(params[:id])
    end

    def authorize_cliente!
      unless @frete.cliente == current_cliente
        redirect_to fretes_path, alert: "Acesso não autorizado."
      end
    end

    def frete_params
      params.require(:frete).permit(
        :origem, :destino, :descricao,
        :peso, :largura, :altura, :profundidade
      )
    end
end
