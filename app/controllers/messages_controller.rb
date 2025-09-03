# frozen_string_literal: true
class MessagesController < ApplicationController
  before_action :authenticate_cliente!, only: [:create]
  before_action :set_frete
  before_action :ensure_cotacao_aceita

  # GET /fretes/:frete_id/chat
  def index
    @messages = @frete.messages.includes(:frete).order(created_at: :asc)
    @message  = @frete.messages.build
  end

  # POST /fretes/:frete_id/messages
  def create
    @message = @frete.messages.build(message_params)
    @message.sender = current_cliente || current_transportador

    if @message.save
      respond_to do |format|
        format.html { redirect_to frete_chat_path(@frete), notice: "Mensagem enviada." }
        format.turbo_stream # Turbo Streams → chat em tempo real
      end
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def set_frete
    @frete = Frete.find(params[:frete_id])
  end

  def ensure_cotacao_aceita
    unless @frete.cotacao_aceita
      redirect_to @frete, alert: "O chat só abre após uma cotação ser aceita."
    end
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
