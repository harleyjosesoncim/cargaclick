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
  # STATUS DE CADASTRO (FASES)
  # =====================================================
  enum status_cadastro: {
    incompleto: 0,
    basico: 1,
    completo: 2
  }, _default: :incompleto

  # =====================================================
  # TIPO DE TRANSPORTADOR
  # =====================================================
  enum tipo: {
    pf: "pf",
    pj: "pj"
  }, _default: "pf"

  # =====================================================
  # STATUS OPERACIONAL
  # =====================================================
  enum status: {
    ativo: 0,
    inativo: 1,
    suspenso: 2
  }, _default: :ativo

  # =====================================================
  # VALIDAÇÕES BÁSICAS (FASE 1)
  # =====================================================
  validates :nome, presence: true, length: { minimum: 2, maximum: 100 }
  validates :telefone, presence: true

  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  # =====================================================
  # DOCUMENTOS (FASE 2 - CADASTRO COMPLETO)
  # =====================================================
  validates :cpf,
            presence: true,
            length: { is: 11 },
            numericality: { only_integer: true },
            if: :cpf_obrigatorio?

  validates :cnpj,
            presence: true,
            length: { is: 14 },
            numericality: { only_integer: true },
            if: :cnpj_obrigatorio?

  # =====================================================
  # DADOS BANCÁRIOS / PIX (EFI)
  # =====================================================
  validates :pix_chave,
            presence: true,
            if: :pix_obrigatorio?

  # =====================================================
  # CALLBACKS
  # =====================================================
  before_validation :normalizar_documentos
  before_save :normalize_email

  # =====================================================
  # REGRAS DE NEGÓCIO
  # =====================================================
  def ativo?
    status == "ativo"
  end

  def pode_receber_pagamento?
    ativo? && cadastro_completo? && pix_chave.present?
  end

  def display_name
    "#{nome} (#{tipo.upcase})"
  end

  private

  # =====================================================
  # CONDIÇÕES
  # =====================================================
  def cadastro_completo?
    status_cadastro == "completo"
  end

  def cpf_obrigatorio?
    cadastro_completo? && pf?
  end

  def cnpj_obrigatorio?
    cadastro_completo? && pj?
  end

  def pix_obrigatorio?
    cadastro_completo?
  end

  # =====================================================
  # NORMALIZAÇÕES
  # =====================================================
  def normalizar_documentos
    self.cpf  = nil if pj?
    self.cnpj = nil if pf?
  end

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
end
