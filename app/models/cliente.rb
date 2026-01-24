# frozen_string_literal: true

class Cliente < ApplicationRecord
  # === AUTENTICAÇÃO (Devise) =========================
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # === ASSOCIAÇÕES ==================================
  has_many :fretes, dependent: :destroy
  has_many :cotacoes, through: :fretes
  has_many :pagamentos, through: :fretes
  has_many :messages, as: :sender, dependent: :destroy

  # === ATRIBUTOS TIPADOS =============================
  # Evita erro: "Undeclared attribute type for enum"
  attribute :status_cadastro, :integer

  # === ENUMS ========================================
  enum status_cadastro: {
    incompleto: 0,
    basico: 1,
    completo: 2
  }, _default: :incompleto

  enum tipo: {
    pf: "pf",
    pj: "pj"
  }, _default: "pf"

  # === VALIDAÇÕES ===================================
  validates :nome,
            presence: true,
            length: { minimum: 2, maximum: 100 }

  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :observacoes,
            length: { maximum: 200 },
            allow_blank: true

  # Documento obrigatório SOMENTE quando cadastro estiver completo
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

  # === CALLBACKS ====================================
  before_validation :normalizar_documentos
  before_save :normalize_email

  # === REGRAS DE NEGÓCIO =============================
  def assinante?
    pj? && fidelidade_ativa?
  end

  def fidelidade?
    fidelidade_ativa?
  end

  def avulso?
    pf? && !fidelidade_ativa?
  end

  # === APRESENTAÇÃO ================================
  def display_name
    "#{nome} (#{tipo.upcase})"
  end

  private

  # === CONDIÇÕES DE VALIDAÇÃO =======================
  def cadastro_completo?
    status_cadastro == "completo"
  end

  def cpf_obrigatorio?
    cadastro_completo? && pf?
  end

  def cnpj_obrigatorio?
    cadastro_completo? && pj?
  end

  # === NORMALIZAÇÃO ================================
  def normalizar_documentos
    self.cpf  = nil if pj?
    self.cnpj = nil if pf?
  end

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
end
