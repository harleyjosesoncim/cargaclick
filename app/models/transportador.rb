# frozen_string_literal: true

class Transportador < ApplicationRecord
  # =====================================================
  # DEVISE
  # =====================================================
  devise :database_authenticatable,
         :registerable,
         :recoverable,
         :rememberable,
         :validatable

  # =====================================================
  # VALIDAÇÕES BÁSICAS
  # =====================================================
  validates :nome, presence: true
  validates :telefone, presence: true

  # =====================================================
  # STATUS / ATIVAÇÃO
  # =====================================================
  def ativo?
    activated_at.present?
  end
end
