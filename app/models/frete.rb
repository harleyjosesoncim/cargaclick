# frozen_string_literal: true

class Frete < ApplicationRecord
  # === ASSOCIAÇÕES ==================================
  belongs_to :cliente
  has_many :cotacoes, dependent: :destroy
  has_many :transportadores, through: :cotacoes

  # 🔹 Transportador escolhido (vencedor da cotação)
  belongs_to :transportador, optional: true

  has_many :messages, dependent: :destroy
  has_many :pagamentos, dependent: :destroy

  # === ENUMS ========================================
  enum status: {
    pendente: 0,
    em_andamento: 1,
    entregue: 2,
    cancelado: 3
  }, _default: :pendente

  # === VALIDAÇÕES ===================================
  validates :cep_origem, :cep_destino, presence: true,
            format: { with: /\A\d{5}-\d{3}\z/, message: "deve estar no formato 00000-000" }

  validates :valor_estimado, :valor_total,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  validates :status, inclusion: { in: statuses.keys }

  # 🔹 Regra de negócio: precisa ter transportador se não estiver mais pendente
  validate :transportador_obrigatorio_quando_em_andamento_ou_entregue

  # === CALLBACKS ====================================
  before_save :normalize_ceps

  private

  def normalize_ceps
    self.cep_origem  = cep_origem.strip.gsub(/\D/, '')&.insert(5, '-') if cep_origem.present?
    self.cep_destino = cep_destino.strip.gsub(/\D/, '')&.insert(5, '-') if cep_destino.present?
  end

  def transportador_obrigatorio_quando_em_andamento_ou_entregue
    if (em_andamento? || entregue?) && transportador_id.blank?
      errors.add(:transportador, "deve ser definido quando o frete está em andamento ou entregue")
    end
  end
end
