# app/models/historico_proposta.rb
class HistoricoProposta < ApplicationRecord
  # === ASSOCIAÇÕES ==================================
  belongs_to :frete

  # === ENUMS (opcional) =============================
  # enum status: { rascunho: 0, enviada: 1, aceita: 2, rejeitada: 3 }

  # === VALIDAÇÕES ===================================
  validates :valor,
            numericality: { greater_than_or_equal_to: 0, allow_nil: true }

  validates :observacoes,
            length: { maximum: 2000 },
            allow_blank: true

  validate :valor_ou_observacao_presente

  # === CALLBACKS ====================================
  before_validation :normalizar_valor

  # === SCOPES =======================================
  scope :recentes,     -> { order(created_at: :desc) }
  scope :acima_de,     ->(minimo) { where("valor >= ?", minimo) if minimo.present? }
  scope :abaixo_de,    ->(maximo) { where("valor <= ?", maximo) if maximo.present? }
  scope :entre_valores, ->(minimo, maximo) {
    where("valor BETWEEN ? AND ?", minimo, maximo) if minimo.present? && maximo.present?
  }

  # === VISUALIZAÇÃO AMIGÁVEL ========================
  def to_s
    valor_fmt = valor.present? ? "R$ #{'%.2f' % valor}" : "sem valor"
    obs_fmt   = observacoes.present? ? observacoes.truncate(40) : "sem observações"
    "Proposta [Frete ##{frete_id}] - #{valor_fmt} - #{obs_fmt}"
  end

  private

  def normalizar_valor
    self.valor ||= 0
  end

  def valor_ou_observacao_presente
    if valor.blank? && observacoes.blank?
      errors.add(:base, "É necessário informar pelo menos um valor ou uma observação.")
    end
  end
end

