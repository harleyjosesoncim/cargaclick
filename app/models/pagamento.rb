# app/models/pagamento.rb
class Pagamento < ApplicationRecord
  # === ASSOCIAÇÕES ==================================
  belongs_to :frete
  belongs_to :transportador

  # Delegações para facilitar uso em relatórios e views
  delegate :descricao, to: :frete, prefix: true, allow_nil: true
  delegate :nome, :email, to: :transportador, prefix: true, allow_nil: true

  # === VALIDAÇÕES ===================================
  validates :valor,
            presence: true,
            numericality: {
              greater_than_or_equal_to: 0,
              less_than: 1_000_000
            }

  validates :status, presence: true

  # === STATUS (enum) ================================
  # Usando string como valor, para maior clareza
  enum status: {
    pendente:   "pendente",
    confirmado: "confirmado",
    cancelado:  "cancelado"
  }, _default: "pendente"

  # === SCOPES ÚTEIS ================================
  scope :recentes,    -> { order(created_at: :desc) }
  scope :pendentes,   -> { where(status: "pendente") }
  scope :confirmados, -> { where(status: "confirmado") }
  scope :cancelados,  -> { where(status: "cancelado") }

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

  # === TRANSIÇÕES DE STATUS =========================
  validate :status_transition_valid?, on: :update

  def status_transition_valid?
    if status_changed?
      if status_was == "confirmado" && status == "pendente"
        errors.add(:status, "não pode voltar para pendente após confirmação")
      end
      if status_was == "cancelado" && status == "confirmado"
        errors.add(:status, "não pode ser confirmado após cancelado")
      end
    end
  end

  # === VISUALIZAÇÃO AMIGÁVEL ========================
  def to_s
    "💸 Pagamento ##{id} | Frete ##{frete_id} | Transportador ##{transportador_id} | " \
    "#{status_label} | R$ #{'%.2f' % valor}"
  end

  def status_label
    I18n.t("pagamentos.status.#{status}", default: status.titleize)
  end

  private

  def set_default_status
    self.status ||= "pendente"
  end
end
# frozen_string_literal: true