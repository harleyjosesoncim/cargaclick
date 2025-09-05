# frozen_string_literal: true

class ChatsController < ApplicationController
  before_action :authenticate_any_user!
  before_action :set_chat, only: [:show]

  # GET /chats
  # Lista todos os chats ativos do usuário logado
  def index
    if current_cliente
      @chats = Chat.joins(:frete)
                   .where(fretes: { cliente_id: current_cliente.id, status: "em_negociacao" })
                   .includes(:frete)
                   .order(updated_at: :desc)
    elsif current_transportador
      @chats = Chat.joins(:frete)
                   .where(fretes: { transportador_id: current_transportador.id, status: "em_negociacao" })
                   .includes(:frete)
                   .order(updated_at: :desc)
    else
      @chats = Chat.none
    end
  end

  # GET /chats/:id
  # Mostra um chat específico e suas mensagens
  def show
    @messages = @chat.messages.order(:created_at)
    @new_message = @chat.messages.build
  end

  private

  # Busca o chat e valida acesso
  def set_chat
    @chat = Chat.find(params[:id])

    unless chat_permitido?(@chat)
      redirect_to chats_path, alert: "Você não tem permissão para acessar este chat."
    end
  end

  # Regra de acesso: só cliente ou transportador envolvidos no frete podem ver
  def chat_permitido?(chat)
    return false unless chat.frete.present?

    (current_cliente && chat.frete.cliente_id == current_cliente.id) ||
      (current_transportador && chat.frete.transportador_id == current_transportador.id)
  end

  # Permite login de cliente OU transportador
  def authenticate_any_user!
    unless current_cliente || current_transportador
      redirect_to new_cliente_session_path, alert: "Faça login para acessar o chat."
    end
  end
end
