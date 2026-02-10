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
  # (APENAS QUANDO CADASTRO ESTIVER COMPLETO)
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
  # SCOPES DE PRODUÇÃO (PASSO 1)
  # =====================================================

  # Transportadores que podem aparecer para o cliente
  scope :operacionais, -> {
    where(status: :ativo, status_cadastro: :completo)
  }

  # Filtro por tipo de veículo (se existir coluna)
  scope :por_tipo_veiculo, ->(tipo) {
    return all if tipo.blank?
    return all unless column_names.include?("tipo_veiculo")

    where(tipo_veiculo: tipo)
  }

  # Scope principal usado após a simulação
  scope :disponiveis_para, ->(resultado) {
    query = operacionais
    query = query.por_tipo_veiculo(resultado[:tipo_veiculo])
    query
  }

  # =====================================================
  # REGRAS DE NEGÓCIO
  # =====================================================
  def pode_operar?
    ativo? && completo?
  end

  private

  # =====================================================
  # NORMALIZAÇÃO
  # =====================================================
  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
end
