class Transportador < ApplicationRecord
  validates :nome, :telefone, :cidade, :tipo_veiculo, presence: true
end
