# frozen_string_literal: true
class ChatsController < ApplicationController
  before_action :authenticate_any_user!
  before_action :set_chat, only: [:show]

  # GET /chats
  def index
    @chats =
      if current_cliente
        current_cliente.chats.includes(:frete, :transportador).order(updated_at: :desc)
      elsif current_transportador
        current_transportador.chats.includes(:frete, :cliente).order(updated_at: :desc)
      elsif current_admin_user
        Chat.includes(:frete, :cliente, :transportador).order(updated_at: :desc)
      else
        []
      end
  end

  # GET /chats/:id
  def show
    @messages = @chat.messages.recent
    @message  = @chat.messages.new
  end

  private

  def set_chat
    @chat = Chat.find(params[:id])
    redirect_to chats_path, alert: "Acesso não autorizado." unless participant?(@chat)
  end

  def participant?(chat)
    (current_cliente && chat.cliente == current_cliente) ||
      (current_transportador && chat.transportador == current_transportador) ||
      current_admin_user.present?
  end

  def authenticate_any_user!
    unless current_cliente || current_transportador || current_admin_user
      redirect_to new_cliente_session_path, alert: "Faça login para acessar o chat."
    end
  end
end
