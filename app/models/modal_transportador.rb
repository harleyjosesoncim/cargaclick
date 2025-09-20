class ModalTransportador < ApplicationRecord
  self.table_name = "modal_transportadores"

  belongs_to :transportador
  belongs_to :modal

  validates :transportador_id, presence: true
  validates :modal_id, presence: true

  # Validações adicionais podem ser adicionadas aqui se necessário
end
