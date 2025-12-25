# app/models/frete.rb
# frozen_string_literal: true

class Frete < ApplicationRecord
  # Associações
  belongs_to :cliente
  belongs_to :transportador, optional: true
  has_many :avaliacoes, dependent: :destroy

  # Enum para status
  enum status: {
    pendente: "pendente",
    aceito: "aceito",
    em_andamento: "em_andamento",
    concluido: "concluido",
    cancelado: "cancelado"
  }

  # Validações
  validates :origem, :destino, presence: true
  validates :valor_estimado, :valor_final,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true
  validates :largura, :altura, :profundidade, :peso_aproximado,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  # ==========================================================
  # Compatibilidade com controllers/views antigos (sem mudar layout)
  # ==========================================================
  def cep_origem
    origem
  end

  def cep_origem=(v)
    self.origem = v
  end

  def cep_destino
    destino
  end

  def cep_destino=(v)
    self.destino = v
  end

  def peso
    peso_aproximado
  end

  def peso=(v)
    self.peso_aproximado = v
  end

  # Valor total usado no checkout (fallback para não quebrar serviços)
  def valor_total
    (valor_final.presence || valor_estimado.presence || 0).to_d
  end

  # Campo usado por algumas telas; mantém compatível
  def descricao
    "Frete #{origem} → #{destino}"
  end
end
