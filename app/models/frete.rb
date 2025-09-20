class Frete < ApplicationRecord
  # Associações
  belongs_to :cliente
  belongs_to :transportador, optional: true
  has_many :avaliacoes, dependent: :destroy

  # Enum para status
  enum status: {
    pendente: "pendente",
    aceito: "aceito",
    em_andamento: "em_andamento",
    concluido: "concluido",
    cancelado: "cancelado"
  }

  # Validações
  validates :origem, :destino, presence: true
  validates :valor_estimado, :valor_final,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true
  validates :largura, :altura, :profundidade, :peso_aproximado,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true
end
