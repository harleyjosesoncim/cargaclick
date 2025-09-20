# app/models/cotacao.rb
# frozen_string_literal: true

class Cotacao < ApplicationRecord
  self.table_name = "cotacoes"

  # === ASSOCIAÇÕES ==================================
  belongs_to :frete
  belongs_to :transportador

  # === ENUMS ========================================
  enum status: { pendente: 0, aprovado: 1, rejeitado: 2 }

  # === VALIDAÇÕES ===================================
  validates :valor,
            presence: true,
            numericality: { greater_than: 0, less_than: 1_000_000 }

  validates :status, presence: true
  validates :comissao,
            numericality: { greater_than_or_equal_to: 0, allow_nil: true }

  # === CALLBACKS ====================================
  before_validation :set_default_status, on: :create
  before_save :calcular_comissao

  # === SCOPES =======================================
  scope :recentes,   -> { order(created_at: :desc) }
  scope :pendentes,  -> { where(status: :pendente) }
  scope :aprovadas,  -> { where(status: :aprovado) }
  scope :rejeitadas, -> { where(status: :rejeitado) }

  # === MÉTODOS DE NEGÓCIO ===========================
  COMISSAO_PADRAO = 0.02 # 2%

  def valor_liquido
    return 0 unless valor.present?
    valor.to_f - comissao.to_f
  end

  def to_s
    "Cotação ##{id} | Frete ##{frete_id} | Transportador ##{transportador_id} | #{status.titleize} | Valor: R$ #{'%.2f' % valor}"
  end

  private

  def set_default_status
    self.status ||= :pendente
  end

  def calcular_comissao
    return unless valor.present?
    self.comissao = [(valor.to_f * COMISSAO_PADRAO), valor.to_f].min.round(2)
  end
end
