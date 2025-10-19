# app/models/cotacao.rb
# frozen_string_literal: true

class Cotacao < ApplicationRecord
  self.table_name = "cotacoes"

  # === ASSOCIAÇÕES ==================================
  belongs_to :frete
  belongs_to :transportador

  # === ENUMS (string-backed) ========================
  # Requer no BD: cotacoes.status :string, default: 'pendente', NOT NULL
  enum status: { pendente: "pendente", aprovado: "aprovado", rejeitado: "rejeitado" },
       _default: "pendente"
  attribute :status, :string, default: "pendente"

  # === VALIDAÇÕES ===================================
  validates :valor,
            presence: true,
            numericality: { greater_than: 0, less_than: 1_000_000 }

  validates :status, presence: true
  validates :comissao,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  # === CALLBACKS ====================================
  before_validation :set_default_status, on: :create
  before_validation :calcular_comissao # calcula antes de validar, mas respeita comissao já definida

  # === SCOPES =======================================
  scope :recentes, -> { order(created_at: :desc) }
  # você também possui escopos gerados pelo enum: .pendente, .aprovado, .rejeitado

  # === CONSTANTES / REGRAS DE NEGÓCIO ===============
  COMISSAO_PADRAO = BigDecimal("0.02") # 2%

  def valor_liquido
    return 0.to_d if valor.blank?
    (valor.to_d - (comissao || 0).to_d).clamp(0.to_d, valor.to_d).round(2)
  end

  def to_s
    "Cotação ##{id} | Frete ##{frete_id} | Transportador ##{transportador_id} | "\
    "#{status.titleize} | Valor: R$ #{format('%.2f', valor.to_d)}"
  end

  private

  def set_default_status
    self.status ||= "pendente"
  end

  def calcular_comissao
    return if valor.blank?
    # Se já definiram a comissão manualmente (admin/serviço), mantém
    return if comissao.present? && comissao.to_d >= 0

    base = valor.to_d
    taxa = if respond_to?(:taxa) && self.taxa.present?
             self.taxa.to_d
           else
             COMISSAO_PADRAO
           end

    calculada = (base * taxa).round(2)
    # nunca maior que o valor
    self.comissao = [calculada, base].min
  end
end
