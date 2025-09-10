# app/models/cliente.rb
# frozen_string_literal: true

class Cliente < ApplicationRecord
  # === AUTENTICAÇÃO (Devise) =========================
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # === ASSOCIAÇÕES ==================================
  has_many :fretes, dependent: :destroy
  has_many :cotacoes, through: :fretes
  has_many :messages, as: :sender, dependent: :destroy   # 🔗 suporte ao chat
  has_many :pagamentos, through: :fretes

  # === VALIDAÇÕES ===================================
  validates :nome, presence: true, length: { minimum: 2, maximum: 100 }

  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :observacoes,
            length: { maximum: 200 },
            allow_blank: true

  # Se o schema tiver cpf/cnpj:
  validates :cpf,
            length: { is: 11 },
            numericality: { only_integer: true },
            allow_blank: true

  validates :cnpj,
            length: { is: 14 },
            numericality: { only_integer: true },
            allow_blank: true

  # === CALLBACKS =====================================
  before_save :normalize_email

  # === ENUMS / TIPOS ================================
  enum tipo: {
    pf: "pf",   # pessoa física → frete avulso
    pj: "pj"    # pessoa jurídica → assinante/fidelizado
  }, _default: "pf"

  # === FIDELIZAÇÃO ==================================
  # Assinantes PJ têm fidelidade e desconto
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

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
end
