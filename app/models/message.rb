# frozen_string_literal: true
class Message < ApplicationRecord
  # === ASSOCIAÇÕES ==================================
  belongs_to :frete
  belongs_to :sender, polymorphic: true   # Cliente, Transportador ou Admin

  # === VALIDAÇÕES ===================================
  validates :content, presence: true, length: { minimum: 1, maximum: 2000 }
  validates :sender_type, :sender_id, presence: true

  # === STATUS (enum) ================================
  enum status: {
    normal: 0,     # mensagem comum
    lido: 1,       # já visualizada
    importante: 2  # destaque
  }, _default: :normal

  # === BROADCAST (Turbo Streams) ====================
  after_create_commit -> { broadcast_append_to "frete_#{frete_id}_messages" }

  # === SCOPES =======================================
  scope :recent,           -> { order(created_at: :asc) }
  scope :do_cliente,       -> { where(sender_type: "Cliente") }
  scope :do_transportador, -> { where(sender_type: "Transportador") }
  scope :do_admin,         -> { where(sender_type: "AdminUser") }
  scope :nao_lidas,        -> { where(status: :normal) }

  # === MÉTODOS DE AÇÃO (BOTÕES) =====================
  def mark_as_read!
    update!(status: :lido)
  end

  def mark_as_important!
    update!(status: :importante)
  end

  # === MÉTODOS AUXILIARES ==========================
  def short_preview
    content.truncate(40)
  end

  # === VISUALIZAÇÃO AMIGÁVEL ========================
  def to_s
    "[#{created_at.strftime('%d/%m %H:%M')}] #{sender_type}##{sender_id}: #{short_preview}"
  end
end
