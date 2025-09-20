# app/models/historico_email.rb
class HistoricoEmail < ApplicationRecord
  # === ASSOCIAÇÕES ==================================
  belongs_to :frete

  # === VALIDAÇÕES ===================================
  validates :assunto, presence: true, length: { maximum: 255 }
  validates :conteudo, presence: true, length: { minimum: 5 }

  # === SCOPES =======================================
  scope :recentes, -> { order(created_at: :desc) }

  # === VISUALIZAÇÃO AMIGÁVEL ========================
  def to_s
    "Email [Frete ##{frete_id}] - #{assunto}: #{conteudo.truncate(40)}"
  end
end
