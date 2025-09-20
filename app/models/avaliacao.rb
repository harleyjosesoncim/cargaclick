class Avaliacao < ApplicationRecord
  # Associações
  belongs_to :frete
  belongs_to :cliente, optional: true
  belongs_to :transportador, optional: true

  # Validações
  validates :nota, presence: true,
                   numericality: { greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }
  validates :comentario, length: { maximum: 500 }, allow_blank: true
end
