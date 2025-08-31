class Frete < ApplicationRecord
  # === ASSOCIAÇÕES ==================================
  belongs_to :cliente
  has_many :cotacoes, dependent: :destroy

  # 🔹 opcional: se quiser armazenar o transportador escolhido para o frete
  belongs_to :transportador, optional: true

  # === ENUMS ========================================
  enum status: {
    pendente: 0,
    em_andamento: 1,
    entregue: 2,
    cancelado: 3
  }

  # === VALIDAÇÕES ===================================
  validates :cep_origem, :cep_destino, presence: true,
            format: { with: /\A\d{5}-\d{3}\z/, message: "deve estar no formato 00000-000" }

  validates :valor_estimado, :valor_total,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  # === CALLBACKS ====================================
  before_save :normalize_ceps

  private

  def normalize_ceps
    self.cep_origem  = cep_origem.strip if cep_origem.present?
    self.cep_destino = cep_destino.strip if cep_destino.present?
  end
end
