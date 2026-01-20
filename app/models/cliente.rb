# frozen_string_literal: true

class Cliente < ApplicationRecord
  # === AUTENTICAÇÃO (Devise) =========================
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # === ASSOCIAÇÕES ==================================
  has_many :fretes, dependent: :destroy
  has_many :cotacoes, through: :fretes
  has_many :messages, as: :sender, dependent: :destroy
  has_many :pagamentos, through: :fretes

  # === STATUS DE CADASTRO (NOVO) ====================
  enum status_cadastro: {
    incompleto: 0,
    basico: 1,
    completo: 2
  }

  # === VALIDAÇÕES ===================================
  validates :nome, presence: true, length: { minimum: 2, maximum: 100 }

  # Devise exige email → mantemos
  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :observacoes,
            length: { maximum: 200 },
            allow_blank: true

  # CPF/CNPJ SÓ quando cadastro estiver COMPLETO
  validates :cpf,
            length: { is: 11 },
            numericality: { only_integer: true },
            presence: true,
            if: :cadastro_completo?

  validates :cnpj,
            length: { is: 14 },
            numericality: { only_integer: true },
            presence: true,
            if: :cadastro_completo?

  # === CALLBACKS =====================================
  before_save :normalize_email

  # === ENUMS / TIPOS ================================
  enum tipo: {
    pf: "pf",
    pj: "pj"
  }, _default: "pf"

  # === FIDELIZAÇÃO ==================================
  def assinante?
    tipo == "pj" && fidelidade_ativa?
  end

  def fidelidade?
    fidelidade_ativa?
  end

  def avulso?
    tipo == "pf" && !fidelidade_ativa?
  end

  # === AJUDARES =====================================
  def display_name
    "#{nome} (#{tipo.upcase})"
  end

  private

  def cadastro_completo?
    status_cadastro == "completo"
  end

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
end
