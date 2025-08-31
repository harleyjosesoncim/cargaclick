class Transportador < ApplicationRecord
  self.table_name = "transportadores"

  # === ASSOCIAÇÕES ==================================
  has_many :cotacoes, dependent: :destroy
  has_many :fretes, through: :cotacoes
  has_many :messages, as: :sender, dependent: :destroy   # 🔗 suporte ao chat

  # === VALIDAÇÕES ===================================
  validates :nome, presence: true, length: { minimum: 2, maximum: 100 }
  validates :cpf, presence: true, uniqueness: true,
                  format: { with: /\A\d{11}\z/, message: "deve conter 11 dígitos numéricos" }

  # === CALLBACKS ====================================
  after_initialize { self.fidelidade_pontos ||= 0 }

  # === MÉTODOS DE NEGÓCIO ===========================
  def adicionar_pontos!(qtd)
    increment!(:fidelidade_pontos, qtd.to_i.clamp(0, 100))
  end
end

