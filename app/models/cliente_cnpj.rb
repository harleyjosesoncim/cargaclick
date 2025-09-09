class ClienteCnpj < ApplicationRecord
  # Relacionamentos
  has_many :fretes, dependent: :nullify

  # Validações
  validates :nome_fantasia, :cnpj, :email, presence: true
  validates :cnpj, uniqueness: true
  validates :email, uniqueness: true
end
# frozen_string_literal: true
# == Schema Information
# Table name: cliente_cnpjs
#  id             :bigint           not null, primary key
#  nome_fantasia :              