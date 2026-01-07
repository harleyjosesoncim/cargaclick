class Transportador < ApplicationRecord
  # ============================
  # VALIDAÇÕES
  # ============================
  validates :nome, :telefone, presence: true

  validates :cidade, :tipo_veiculo,
            presence: true,
            if: :ativo?

  # ============================
  # ATIVAÇÃO
  # ============================
  def ativo?
    activated_at.present?
  end
end
