# frozen_string_literal: true

class Frete < ApplicationRecord
  # ==========================================================
  # ASSOCIAÇÕES
  # ==========================================================
  belongs_to :cliente
  belongs_to :transportador, optional: true

  has_many :avaliacoes, dependent: :destroy
  has_one  :cotacao, dependent: :destroy

  # ==========================================================
  # ENUM STATUS
  # ==========================================================
  enum status: {
    pendente:      "pendente",
    aceito:        "aceito",
    em_andamento:  "em_andamento",
    concluido:     "concluido",
    cancelado:     "cancelado"
  }

  # ==========================================================
  # VALIDAÇÕES
  # ==========================================================
  validates :origem, :destino, presence: true

  validates :valor_estimado, :valor_final,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  validates :largura, :altura, :profundidade, :peso_aproximado,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  # ==========================================================
  # 🔄 COMPATIBILIDADE COM CÓDIGO LEGADO
  # (NÃO REMOVER – evita retrabalho)
  # ==========================================================
  def cep_origem
    origem
  end

  def cep_origem=(valor)
    self.origem = valor
  end

  def cep_destino
    destino
  end

  def cep_destino=(valor)
    self.destino = valor
  end

  def peso
    peso_aproximado
  end

  def peso=(valor)
    self.peso_aproximado = valor
  end

  # ==========================================================
  # 💰 VALOR USADO EM PAGAMENTO (SAFE)
  # ==========================================================
  def valor_total
    valor_final.presence ||
      valor_estimado.presence ||
      BigDecimal("0")
  end

  # ==========================================================
  # 🧠 DESCRIÇÃO PADRÃO (UI / BOT / LOGS)
  # ==========================================================
  def descricao
    "Frete #{origem} → #{destino}"
  end

  # ==========================================================
  # 📏 CÁLCULO DE VALOR POR DISTÂNCIA (ORS)
  # ==========================================================
  VALOR_POR_KM = 2.50

  def calcular_valor!(distancia_km)
    return if distancia_km.blank?

    update!(
      distancia_km: distancia_km,
      valor_estimado: (distancia_km * VALOR_POR_KM).round(2)
    )
  end
end
