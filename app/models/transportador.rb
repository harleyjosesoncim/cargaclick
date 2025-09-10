# app/models/transportador.rb
# frozen_string_literal: true

class Transportador < ApplicationRecord
  # === AUTENTICAÇÃO (Devise) =========================
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable,
         :confirmable
         # :lockable, :timeoutable, :trackable, :omniauthable

  self.table_name = "transportadores"

  # === ASSOCIAÇÕES ==================================
  has_many :cotacoes, dependent: :destroy
  has_many :fretes, through: :cotacoes
  has_many :messages, as: :sender, dependent: :destroy   # 🔗 suporte ao chat
  has_many :pagamentos, dependent: :destroy             # 🔗 histórico financeiro

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

  validates :chave_pix,
            presence: true,
            uniqueness: true,
            length: { maximum: 100 }

  # === CALLBACKS ====================================
  after_initialize do
    self.fidelidade_pontos ||= 0 if has_attribute?(:fidelidade_pontos)
  end

  # === STATUS / ENUMS ===============================
  enum status: {
    ativo: "ativo",
    suspenso: "suspenso"
  }, _default: "ativo"

  # === MÉTODOS DE NEGÓCIO ===========================
  # Incrementa pontos de fidelidade (máx. 100 por vez)
  def adicionar_pontos!(qtd)
    increment!(:fidelidade_pontos, qtd.to_i.clamp(0, 100))
  end

  def fidelidade_bonus?
    fidelidade_pontos >= 100
  end

  def resetar_pontos!
    update!(fidelidade_pontos: 0)
  end

  # === VISUALIZAÇÃO PARA BOTÕES/PAINEL ==============
  def display_name
    "#{nome} (##{id})"
  end

  def status_label
    ativo? ? "🟢 Ativo" : "🔴 Suspenso"
  end

  def pontos_label
    "⭐ #{fidelidade_pontos} pontos"
  end

  # Para views: botão de pagamento só aparece se PIX estiver configurado
  def pode_receber_pagamento?
    chave_pix.present? && ativo?
  end
end
# == Schema Information
# Table name: transportadores
#  id                 :bigint           not null, primary key
#  nome               :string(100)      not null
#  cpf                :string(11)       not null
#  email              :string(255)      not null
#  encrypted_password :string(255)      not null