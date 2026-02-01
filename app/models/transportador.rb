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
  # TIPO DE PESSOA
  # =====================================================
  enum tipo_pessoa: {
    pf: 0,
    pj: 1
  }, _prefix: true

  # =====================================================
  # STATUS DE CADASTRO (ONBOARDING)
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
  # VALIDAÇÕES GERAIS
  # =====================================================
  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  # =====================================================
  # VALIDAÇÕES CONDICIONAIS PF / PJ
  # (SÓ QUANDO CADASTRO ESTIVER COMPLETO)
  # =====================================================
  validates :cpf,
            presence: true,
            uniqueness: true,
            if: -> { tipo_pessoa_pf? && completo? }

  validates :cnpj,
            presence: true,
            uniqueness: true,
            if: -> { tipo_pessoa_pj? && completo? }

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
