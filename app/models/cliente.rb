class Cliente < ApplicationRecord
  # === AUTENTICAÇÃO (Devise) =========================
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # === ASSOCIAÇÕES ==================================
  has_many :fretes, dependent: :destroy
  has_many :cotacoes, through: :fretes
  has_many :messages, as: :sender, dependent: :destroy   # 🔗 suporte ao chat

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
  validates :cpf, length: { is: 11 },
                  numericality: { only_integer: true },
                  allow_blank: true

  # === CALLBACKS =====================================
  before_save :normalize_email

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end
end

