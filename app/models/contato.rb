# app/models/contato.rb
class Contato < ApplicationRecord
  validates :nome, :email, :mensagem, presence: true
end
