# frozen_string_literal: true
class Cotacao < ApplicationRecord
  self.table_name = "cotacoes"

  # === ASSOCIAÇÕES ==================================
  belongs_to :frete
  belongs_to :transportador

  # === VALIDAÇÕES ===================================
  validates :valor,
            presence: true,
            numericality: { greater_than: 0, less_than: 1_000_000 }

  validates :status,
            presence: true,
            inclusion: { in: %w[pendente aprovado rejeitado] }

  # === CALLBACKS ====================================
  before_validation :set_default_status, on: :create
  before_save :calcular_comissao

  # === SCOPES =======================================
  scope :pendentes,  -> { where(status: "pendente") }
  scope :aprovadas,  -> { where(status: "aprovado") }
  scope :rejeitadas, -> { where(status: "rejeitado") }

  # === MÉTODOS DE NEGÓCIO ===========================
  COMISSAO_PADRAO = 0.02 # 2% valor da comissão   

  def valor_liquido
    valor.to_f - comissao.to_f
  end

  private

  def set_default_status
    self.status ||= "pendente"
  end

  def calcular_comissao
    self.comissao = (valor.to_f * COMISSAO_PADRAO).round(2)
  end
end

