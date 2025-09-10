# frozen_string_literal: true
class MessagesController < ApplicationController
  before_action :authenticate_any_user!
  before_action :set_frete
  before_action :ensure_frete_access!
  before_action :set_message, only: [:mark_as_read, :mark_as_important]

  # GET /fretes/:frete_id/messages
  def index
    @messages = @frete.messages.includes(:sender).order(created_at: :asc)
    @message  = @frete.messages.new
  end

  # POST /fretes/:frete_id/messages
  def create
    @message = @frete.messages.new(message_params)
    @message.sender = current_cliente || current_transportador || current_admin_user

    if @message.save
      respond_to do |format|
        format.html { redirect_to frete_messages_path(@frete), notice: "Mensagem enviada." }
        format.turbo_stream # Hotwire/Turbo → entrega em tempo real
      end
    else
      render :index, status: :unprocessable_entity
    end
  end

  # PATCH /fretes/:frete_id/messages/:id/mark_as_read
  def mark_as_read
    @message.mark_as_read!
    redirect_to frete_messages_path(@frete), notice: "Mensagem marcada como lida."
  end

  # PATCH /fretes/:frete_id/messages/:id/mark_as_important
  def mark_as_important
    @message.mark_as_important!
    redirect_to frete_messages_path(@frete), notice: "Mensagem destacada como importante."
  end

  private

  def set_frete
    @frete = Frete.find(params[:frete_id])
  end

  def set_message
    @message = @frete.messages.find(params[:id])
  end

  def ensure_frete_access!
    unless (current_cliente && @frete.cliente == current_cliente) ||
           (current_transportador && @frete.transportador == current_transportador) ||
           current_admin_user.present?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end

  def authenticate_any_user!
    unless current_cliente || current_transportador || current_admin_user
      redirect_to new_cliente_session_path, alert: "Faça login para acessar as mensagens."
    end
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
