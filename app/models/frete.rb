class Frete < ApplicationRecord
  before_validation :normalize_ceps

  validates :cep_origem, :cep_destino, presence: { message: "não pode ficar em branco" }
  validate  :ceps_validos

  validates :peso, numericality: { greater_than: 0 }, allow_nil: true
  validates :largura, :altura, :profundidade,
            numericality: { greater_than_or_equal_to: 0 }, allow_nil: true

  private

  def normalize_ceps
    self.cep_origem  = format_cep(cep_origem)
    self.cep_destino = format_cep(cep_destino)
  end

  def format_cep(value)
    digits = value.to_s.gsub(/[^0-9]/, "")[0, 8]
    return nil if digits.blank?
    return digits if digits.length < 8
    "#{digits[0..4]}-#{digits[5..7]}"
  end

  def ceps_validos
    errors.add(:cep_origem,  "inválido (use 00000-000)")  if cep_origem.present?  && format_cep(cep_origem).to_s.length != 9
    errors.add(:cep_destino, "inválido (use 00000-000)") if cep_destino.present? && format_cep(cep_destino).to_s.length != 9
  end
end
