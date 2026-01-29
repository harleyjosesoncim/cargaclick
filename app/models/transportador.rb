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
  # STATUS DE CADASTRO
  # =====================================================
  enum status_cadastro: {
    incompleto: 0,
    basico: 1,
    completo: 2
  }, _default: :incompleto

  # =====================================================
  # STATUS OPERACIONAL
  # =====================================================
  enum status: {
    ativo: 0,
    inativo: 1,
    suspenso: 2
  }, _default: :ativo

  # =====================================================
  # VALIDAÇÕES MÍNIMAS (SMOKE / FASE 1)
  # =====================================================
  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  # =====================================================
  # CALLBACKS
  # =====================================================
  before_save :normalize_email

  # =====================================================
  # REGRAS DE NEGÓCIO
  # =====================================================
  def pode_operar?
    ativo? && completo?
  end

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
end
