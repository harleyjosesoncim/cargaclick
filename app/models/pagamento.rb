# app/models/pagamento.rb
class Pagamento < ApplicationRecord
  # === ASSOCIAÇÕES ==================================
  belongs_to :frete
  belongs_to :transportador

  # === VALIDAÇÕES ===================================
  validates :valor,
            presence: true,
            numericality: { greater_than_or_equal_to: 0, less_than: 1_000_000 }

  validates :status, presence: true

  # === STATUS (enum) ================================
  enum status: {
    pendente: "pendente",
    confirmado: "confirmado",
    cancelado: "cancelado"
  }, _default: "pendente"

  # === SCOPES ÚTEIS ================================
  scope :recentes, -> { order(created_at: :desc) }
  scope :pendentes, -> { where(status: "pendente") }
  scope :confirmados, -> { where(status: "confirmado") }
  scope :cancelados, -> { where(status: "cancelado") }

  # === CALLBACKS ====================================
  before_validation :set_default_status, on: :create

  # === MÉTODOS DE NEGÓCIO ===========================
  def confirmar!
    update!(status: "confirmado")
  end

  def cancelar!
    update!(status: "cancelado")
  end

  def pendente?
    status == "pendente"
  end

  # === VISUALIZAÇÃO AMIGÁVEL ========================
  def to_s
    "Pagamento ##{id} - Frete ##{frete_id} - Transportador ##{transportador_id} - #{status.titleize} - R$ #{'%.2f' % valor}"
  end

  private

  def set_default_status
    self.status ||= "pendente"
  end
end
