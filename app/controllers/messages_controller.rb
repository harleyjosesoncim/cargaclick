# frozen_string_literal: true
class MessagesController < ApplicationController
  before_action :authenticate_any_user!
  before_action :set_chat
  before_action :ensure_chat_access!

  # GET /chats/:chat_id/messages
  def index
    @messages = @chat.messages.includes(:sender).order(created_at: :asc)
    @message  = @chat.messages.new
  end

  # POST /chats/:chat_id/messages
  def create
    @message = @chat.messages.new(message_params)
    @message.sender = current_cliente || current_transportador || current_admin_user

    if @message.save
      respond_to do |format|
        format.html { redirect_to chat_path(@chat), notice: "Mensagem enviada." }
        format.turbo_stream # Hotwire → entrega em tempo real
      end
    else
      render :index, status: :unprocessable_entity
    end
  end

  private

  def set_chat
    @chat = Chat.find(params[:chat_id])
  end

  def ensure_chat_access!
    unless (current_cliente && @chat.cliente == current_cliente) ||
           (current_transportador && @chat.transportador == current_transportador) ||
           current_admin_user.present?
      redirect_to root_path, alert: "Acesso não autorizado."
    end
  end

  def authenticate_any_user!
    unless current_cliente || current_transportador || current_admin_user
      redirect_to new_cliente_session_path, alert: "Faça login para acessar o chat."
    end
  end

  def message_params
    params.require(:message).permit(:content)
  end
end
