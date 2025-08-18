# frozen_string_literal: true

class FretesController < ApplicationController
  # /bolsao hoje aponta para fretes#queue; ambos são públicos
  before_action :authenticate_cliente!, except: %i[bolsao queue]
  before_action :set_frete, only: %i[show]

  rescue_from ActiveRecord::RecordNotFound, with: :render_404

  # GET /fretes
  def index
    @fretes = current_cliente.fretes.order(created_at: :desc).limit(50)
  end

  # GET /fretes/new
  def new
    @frete = current_cliente.fretes.build
  end

  # POST /fretes
  def create
    @frete = current_cliente.fretes.build(frete_params)
    if @frete.save
      redirect_to @frete, notice: 'Frete criado com sucesso.'
    else
      flash.now[:error] = 'Revise os campos abaixo.'
      render :new, status: :unprocessable_entity
    end
  end

  # GET /fretes/:id
  def show; end

  # GET /bolsao (público) – usa app/views/fretes/bolsao.html.erb
  def bolsao
    scope = Frete
    scope = scope.where(publico: true) if Frete.column_names.include?('publico')
    @fretes = scope.order(created_at: :desc).limit(50)
    expires_in 60.seconds, public: true
    render :bolsao
  end

  # Compatível com a rota atual: fretes#queue
  def queue
    bolsao
  end

  private

  def set_frete
    @frete = current_cliente.fretes.find(params[:id])
  end

  def frete_params
    params.require(:frete).permit(:origem, :destino, :descricao,
                                  :peso, :largura, :altura, :profundidade, :publico)
  end

  def render_404
    render file: Rails.root.join('public/404.html'), status: :not_found, layout: false
  end
end
