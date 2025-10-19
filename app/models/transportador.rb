# app/models/transportador.rb
# frozen_string_literal: true

class Transportador < ApplicationRecord
  # ===================== Devise =====================
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable
  # :lockable, :timeoutable, :trackable, :omniauthable (adicione se precisar)

  self.table_name = "transportadores"

  # ================== Associações ===================
  has_many :cotacoes,   dependent: :destroy
  has_many :fretes,     through: :cotacoes
  has_many :messages,   as: :sender, dependent: :destroy
  has_many :pagamentos, dependent: :destroy

  # =================== Constantes ===================
  TIPOS_VEICULO = %w[Carro Moto VUC Toco 3/4 Truck Cavalo Bitrem].freeze

  # ===================== Enums ======================
  # Compatível com estados legados e atual (string-backed).
  # Garanta no BD: status:string NOT NULL default 'ativo'
  enum status: {
    pendente:  "pendente",  # legado (se existia)
    ativo:     "ativo",
    suspenso:  "suspenso",
    bloqueado: "bloqueado"  # legado (se existia)
  }, _default: "ativo", _prefix: true

  # Defaults em nível de modelo (boa prática mesmo com default no BD)
  attribute :status, :string, default: "ativo"
  attribute :fidelidade_pontos, :integer, default: 0

  # ================ Normalizações ===================
  before_validation :normalize_campos
  before_validation :ensure_default_status, on: :create

  # =================== Validações ===================
  validates :nome, presence: true, length: { minimum: 2, maximum: 100 }

  validates :cpf,
            presence: true,
            uniqueness: true,
            format: { with: /\A\d{11}\z/, message: "deve conter 11 dígitos numéricos" }
  validate  :cpf_checksum

  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  validates :cidade,       presence: true, length: { maximum: 100 }
  validates :tipo_veiculo, presence: true, inclusion: { in: TIPOS_VEICULO }
  validates :carga_maxima, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :valor_km,     presence: true, numericality: { greater_than: 0 }

  validates :chave_pix,
            presence: true,
            uniqueness: true,
            length: { maximum: 100 }

  # ==================== Scopes ======================
  scope :ativos, -> { where(status: statuses[:ativo]) }

  # ============== Métodos de negócio ===============
  def adicionar_pontos!(qtd)
    increment!(:fidelidade_pontos, qtd.to_i.clamp(0, 100))
  end

  def fidelidade_bonus? = fidelidade_pontos >= 100
  def resetar_pontos!   = update!(fidelidade_pontos: 0)

  def display_name = "#{nome} (##{id})"

  def status_label
    case status
    when "ativo"     then "🟢 Ativo"
    when "suspenso"  then "🟠 Suspenso"
    when "bloqueado" then "🔴 Bloqueado"
    else                  "🟡 Pendente"
    end
  end

  def pontos_label = "⭐ #{fidelidade_pontos} pontos"

  def pode_receber_pagamento?
    chave_pix.present? && ativo?
  end

  # ============== Utilidades de seed ===============
  # insert_all/upsert_all pulam callbacks/defaults/validações.
  # Use este helper para criação/atualização segura preservando normalizações.
  def self.safe_create_or_update!(attrs)
    email = attrs[:email] || attrs["email"]
    record = find_or_initialize_by(email: email.to_s.downcase.strip)
    record.assign_attributes(attrs)
    record.save!
    record
  end

  private

  def ensure_default_status
    self.status ||= "ativo"
  end

  def normalize_campos
    self.nome         = nome.to_s.strip
    self.email        = email.to_s.strip.downcase
    self.cpf          = cpf.to_s.gsub(/\D/, "") # apenas dígitos
    self.cidade       = cidade.to_s.strip
    self.chave_pix    = chave_pix.to_s.strip
    self.tipo_veiculo = tipo_veiculo.to_s.strip
  end

  # Validação simples de CPF (dois dígitos verificadores)
  def cpf_checksum
    num = cpf.to_s
    return if num.blank? || num.length != 11 || num.chars.uniq.length == 1

    digits = num.chars.map(&:to_i)
    v1 = calc_cpf_digit(digits[0..8], (10).downto(2).to_a)
    v2 = calc_cpf_digit(digits[0..9], (11).downto(2).to_a)
    errors.add(:cpf, "inválido") unless v1 == digits[9] && v2 == digits[10]
  end

  def calc_cpf_digit(nums, weights)
    sum = nums.zip(weights).sum { |n, w| n * w }
    mod = sum % 11
    mod < 2 ? 0 : 11 - mod
  end
end
