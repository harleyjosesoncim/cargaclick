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
  TIPOS_VEICULO   = %w[Carro Moto VUC Toco 3/4 Truck Cavalo Bitrem].freeze
  TIPOS_DOCUMENTO = %w[CPF CNPJ RG].freeze

  # ===================== Enums ======================
  enum status: {
    pendente:  "pendente",
    ativo:     "ativo",
    suspenso:  "suspenso",
    bloqueado: "bloqueado"
  }, _default: "ativo", _prefix: true

  # Defaults em nível de modelo
  attribute :status, :string,          default: "ativo"
  attribute :fidelidade_pontos, :integer, default: 0

  # ================ Normalizações ===================
  before_validation :normalize_campos
  before_validation :ensure_default_status, on: :create

  # =================== Validações ===================

  # Dados básicos
  validates :nome,   presence: true, length: { minimum: 2, maximum: 100 }
  validates :cidade, presence: true, length: { maximum: 100 }

  # Documentos (CPF / CNPJ / RG)
  validates :tipo_documento,
            presence: true,
            inclusion: { in: TIPOS_DOCUMENTO }

  validates :documento,
            presence: true,
            uniqueness: true,
            length: { maximum: 20 }

  validate :documento_valido

  # E-mail
  validates :email,
            presence: true,
            uniqueness: { case_sensitive: false },
            format: { with: URI::MailTo::EMAIL_REGEXP }

  # Veículo e capacidade
  validates :tipo_veiculo,
            presence: true,
            inclusion: { in: TIPOS_VEICULO }

  validates :carga_maxima,
            presence: true,
            numericality: { greater_than_or_equal_to: 0 }

  validates :valor_km,
            presence: true,
            numericality: { greater_than: 0 }

  # Chave Pix
  validates :chave_pix,
            presence: true,
            uniqueness: true,
            length: { maximum: 100 }

  # Campos específicos para motoqueiro
  # (obrigatórios quando o tipo de veículo for Moto)
  validates :cnh_numero,
            presence: true,
            if: -> { tipo_veiculo == "Moto" }

  validates :placa_veiculo,
            presence: true,
            if: -> { tipo_veiculo == "Moto" }

  # ==================== Scopes ======================
  scope :ativos, -> { where(status: statuses[:ativo]) }

  # ============== Métodos de negócio ===============
  def adicionar_pontos!(qtd)
    increment!(:fidelidade_pontos, qtd.to_i.clamp(0, 100))
  end

  def fidelidade_bonus?
    fidelidade_pontos >= 100
  end

  def resetar_pontos!
    update!(fidelidade_pontos: 0)
  end

  def display_name
    "#{nome} (##{id})"
  end

  def status_label
    case status
    when "ativo"     then "🟢 Ativo"
    when "suspenso"  then "🟠 Suspenso"
    when "bloqueado" then "🔴 Bloqueado"
    else                  "🟡 Pendente"
    end
  end

  def pontos_label
    "⭐ #{fidelidade_pontos} pontos"
  end

  def pode_receber_pagamento?
    chave_pix.present? && ativo?
  end

  # ============== Utilidades de seed ===============
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
    self.nome          = nome.to_s.strip
    self.email         = email.to_s.strip.downcase
    self.cidade        = cidade.to_s.strip
    self.chave_pix     = chave_pix.to_s.strip
    self.tipo_veiculo  = tipo_veiculo.to_s.strip

    self.tipo_documento = tipo_documento.to_s.strip.upcase if tipo_documento.present?

    if tipo_documento.in?(%w[CPF CNPJ]) && documento.present?
      self.documento = documento.to_s.gsub(/\D/, "")
    else
      self.documento = documento.to_s.strip
    end

    self.placa_veiculo = placa_veiculo.to_s.strip.upcase if respond_to?(:placa_veiculo) && placa_veiculo.present?
  end

  # Validação dos documentos conforme o tipo escolhido
  def documento_valido
    case tipo_documento
    when "CPF"
      if documento.blank?
        errors.add(:documento, "não pode ficar em branco")
        return
      end

      somente_digitos = documento.to_s.gsub(/\D/, "")
      unless cpf_valido?(somente_digitos)
        errors.add(:documento, "CPF inválido (deve ter 11 dígitos válidos)")
      end

    when "CNPJ"
      if documento.blank?
        errors.add(:documento, "não pode ficar em branco")
        return
      end

      somente_digitos = documento.to_s.gsub(/\D/, "")
      unless somente_digitos =~ /\A\d{14}\z/
        errors.add(:documento, "CNPJ deve conter 14 dígitos numéricos")
      end

    when "RG"
      errors.add(:documento, "não pode ficar em branco") if documento.blank?

    else
      errors.add(:tipo_documento, "inválido")
    end
  end

  # Validação simples de CPF (dois dígitos verificadores)
  def cpf_valido?(num)
    num = num.to_s
    return false if num.blank? || num.length != 11 || num.chars.uniq.length == 1

    digits = num.chars.map(&:to_i)
    v1 = calc_cpf_digit(digits[0..8], (10).downto(2).to_a)
    v2 = calc_cpf_digit(digits[0..9], (11).downto(2).to_a)
    v1 == digits[9] && v2 == digits[10]
  end

  def calc_cpf_digit(nums, weights)
    sum = nums.zip(weights).sum { |n, w| n * w }
    mod = sum % 11
    mod < 2 ? 0 : 11 - mod
  end
end

