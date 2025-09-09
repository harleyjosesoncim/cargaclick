# frozen_string_literal: true
class Chat < ApplicationRecord
  # === ASSOCIAÇÕES ==================================
  belongs_to :frete
  belongs_to :cliente
  belongs_to :transportador
  has_many   :messages, dependent: :destroy

  # === VALIDAÇÕES ===================================
  validates :frete, :cliente, :transportador, presence: true
  validates :frete_id, uniqueness: { scope: [:cliente_id, :transportador_id],
                                     message: "já possui chat entre cliente e transportador" }

  # === SCOPES =======================================
  scope :ativos,    -> { where(ativo: true) if column_names.include?("ativo") }
  scope :recentes,  -> { order(updated_at: :desc) }

  # === MÉTODOS ======================================
  def last_message
    messages.order(created_at: :desc).first
  end

  def participantes
    [cliente, transportador]
  end

  def to_s
    "Chat Frete ##{frete.id} — Cliente #{cliente.nome} x Transportador #{transportador.nome}"
  end
end
