# frozen_string_literal: true

class FretesController < ApplicationController
  # Exige login para tudo, exceto o bolsão (público)
  before_action :authenticate_cliente!, except: [:bolsao]

  # Carrega e autoriza o frete nas ações privadas
  before_action :set_frete, only: %i[show rastreamento entregar chat gerar_proposta]
  before_action :authorize_cliente!, only: %i[show rastreamento entregar chat gerar_proposta]

  # Em vez de 500, retorna 404 quando o registro não existir
  rescue_from ActiveRecord::RecordNotFound, with: :render_404
  rescue_from ActionController::ParameterMissing, with: :render_422

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
    @frete.cliente = current_cliente

    if @frete.save
      redirect_to @frete, notice: "Frete criado com sucesso!"
    else
      flash.now[:error] = "Revise os campos abaixo."
      render :new, status: :unprocessable_entity
    end
  end

  # GET /fretes/:id
  def show; end

  # GET /fretes/:id/rastreamento
  def rastreamento
    # view/serviço cuidam da exibição
  end

  # POST /fretes/:id/entregar
  def entregar
    unless @frete.respond_to?(:status)
      return redirect_to @frete, alert: "Operação indisponível para este frete."
    end

    if @frete.update(status: :entregue)
      redirect_to @frete, notice: "Frete marcado como entregue!"
    else
      redirect_to @frete, alert: "Não foi possível marcar como entregue."
    end
  end

  # POST /fretes/:id/gerar_proposta
  def gerar_proposta
    unless openai_enabled?
      return render json: { error: "OpenAI desabilitado" }, status: :service_unavailable
    end
    unless defined?(OpenaiService)
      return render json: { error: "Serviço de IA indisponível" }, status: :service_unavailable
    end

    prompt = <<~TXT.squish
      Gere uma proposta comercial para o frete de #{@frete.origem} até #{@frete.destino},
      peso: #{@frete.peso}kg.
    TXT

    proposta = OpenaiService.new(prompt).call
    render json: { proposta: proposta }, status: :ok
  rescue StandardError => e
    Rails.logger.error("[gerar_proposta] #{e.class}: #{e.message}")
    render json: { error: "Falha ao gerar proposta" }, status: :bad_gateway
  end

  # GET /fretes/:id/chat
  def chat
    # lógica do chat (ActionCable/API/JS) fica na view
  end

  # GET /bolsao  (público)
  def bolsao
    # Ajuste o escopo conforme sua regra (ex.: publicados/abertos)
    @fretes = Frete.order(created_at: :desc).limit(50)
  end

  private

  def set_frete
    @frete = Frete.find(params[:id])
  end

  def authorize_cliente!
    unless current_cliente && @frete.cliente_id == current_cliente.id
      redirect_to fretes_path, alert: "Acesso não autorizado."
    end
  end

  def frete_params
    params.require(:frete).permit(
      :origem, :destino, :descricao,
      :peso, :largura, :altura, :profundidade
    )
  end

  # Renderizadores simples (não dependem de layout/partials)
  def render_404
    render file: Rails.root.join("public/404.html"), status: :not_found, layout: false
  end

  def render_422
    render file: Rails.root.join("public/422.html"), status: :unprocessable_entity, layout: false
  end

  def openai_enabled?
    ENV["OPENAI_API_KEY"].present? ||
      (Rails.application.credentials.dig(:openai, :api_key).present? rescue false)
  end
end
