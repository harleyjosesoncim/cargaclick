class Proposta < ApplicationRecord
  belongs_to :frete
  belongs_to :transportador
end
