# app/models/cliente.rb
class Cliente < ApplicationRecord
  # Validações para garantir que nome e email não estejam vazios
  validates :nome, presence: true
  validates :email, presence: true, uniqueness: true # Garante que o email é único
  validates_format_of :email, with: URI::MailTo::EMAIL_REGEXP # Valida o formato do email
end