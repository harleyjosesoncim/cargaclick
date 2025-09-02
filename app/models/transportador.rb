class Transportador < ApplicationRecord
  # === AUTENTICAÇÃO (Devise) =========================
  # Módulos essenciais do Devise
  # Ative/descomente os opcionais conforme necessidade
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable
         # :lockable, :timeoutable, :trackable, :omniauthable

  self.table_name = "transportadores"

  # === ASSOCIAÇÕES ==================================
  has_many :cotacoes, dependent: :destroy
  has_many :fretes, through: :cotacoes
  has_many :messages, as: :sender, dependent: :destroy   # 🔗 suporte ao chat interno

  # === VALIDAÇÕES ===================================
  validates :nome,
            presence: true,
            length: { minimum: 2, maximum: 100 }

  validates :cpf,
            presence: true,
            uniqueness: true,
            format: { with: /\A\d{11}\z/, message: "deve conter 11 dígitos numéricos" }

  validates :email,
            presence: true,
            uniqueness: true,
            format: { with: URI::MailTo::EMAIL_REGEXP }

  # === CALLBACKS ====================================
  after_initialize do
    self.fidelidade_pontos ||= 0 if has_attribute?(:fidelidade_pontos)
  end

  # === MÉTODOS DE NEGÓCIO ===========================
  # Incrementa pontos de fidelidade, limitado a 100 por vez
  def adicionar_pontos!(qtd)
    increment!(:fidelidade_pontos, qtd.to_i.clamp(0, 100))
  end
end
