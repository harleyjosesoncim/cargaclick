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
  # STATUS DE CADASTRO (NOVO)
  # =====================================================
  enum status_cadastro: {
    incompleto: 0,
    basico: 1,
    completo: 2
  }

  # =====================================================
  # VALIDAÇÕES BÁSICAS (FASE 1)
  # =====================================================
  validates :nome, presence: true
  validates :telefone, presence: true

  # =====================================================
  # VALIDAÇÕES CONDICIONAIS (FASE 2)
  # =====================================================
  validates :cpf_cnpj, presence: true, if: :cadastro_completo?
  validates :dados_bancarios, presence: true, if: :cadastro_completo?

  # =====================================================
  # STATUS / ATIVAÇÃO
  # =====================================================
  def ativo?
    activated_at.present?
  end

  private

  def cadastro_completo?
    status_cadastro == "completo"
  end
end
