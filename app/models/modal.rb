class Modal < ApplicationRecord
  has_many :modal_transportadores
  has_many :transportadores, through: :modal_transportadores
end
