class Message < ApplicationRecord
  # === ASSOCIAÇÕES ==================================
  belongs_to :frete
  belongs_to :sender, polymorphic: true   # Cliente ou Transportador

  # === VALIDAÇÕES ===================================
  validates :content, presence: true

  # === STATUS (enum) ================================
  enum status: { unread: 0, read: 1 }, _default: :unread

  # === BROADCAST (Turbo Streams) ====================
  # Isso permite atualização em tempo real no chat
  after_create_commit -> { broadcast_append_to "frete_#{frete_id}_messages" }

  # === SCOPOS ÚTEIS ================================
  scope :recent, -> { order(created_at: :asc) }
  scope :unread, -> { where(status: :unread) }

  # === MÉTODOS ======================================
  def mark_as_read!
    update!(status: :read)
  end
end
