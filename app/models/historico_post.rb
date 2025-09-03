# app/models/historico_post.rb
class HistoricoPost < ApplicationRecord
  # === ASSOCIAÇÕES ==================================
  belongs_to :frete

  # === VALIDAÇÕES ===================================
  validates :conteudo, presence: true, length: { minimum: 2, maximum: 5000 }

  # === SCOPES =======================================
  scope :recentes, -> { order(created_at: :desc) }

  # === VISUALIZAÇÃO AMIGÁVEL ========================
  def to_s
    "Post [Frete ##{frete_id}] - #{conteudo.truncate(50)}"
  end
end
