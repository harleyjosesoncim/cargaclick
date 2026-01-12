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
  # ENUMS (ALINHADOS AO BANCO)
  # ==========================================================

  # Coluna: status (já existente no banco)
  enum status: {
    pendente:     "pendente",
    aceito:       "aceito",
    em_andamento: "em_andamento",
    concluido:    "concluido",
    cancelado:    "cancelado"
  }, _prefix: :frete

  # Coluna: status_pagamento (migration AddPixPinEComissaoToFretes)
  enum status_pagamento: {
    aguardando_pagamento: "aguardando_pagamento",
    pago:                 "pago",
    liberado:             "liberado",
    cancelado:            "cancelado"
  }, _prefix: :pagamento

  # Coluna: pin_status
  enum pin_status: {
    pendente:   "pendente",
    confirmado: "confirmado",
    expirado:   "expirado"
  }, _prefix: :pin

  # ==========================================================
  # CALLBACKS
  # ==========================================================
  before_create :gerar_pin_entrega
  before_validation :definir_comissao_padrao, on: :create

  # ==========================================================
  # 🔐 PIN DE ENTREGA
  # ==========================================================
  def gerar_pin_entrega
    self.pin_entrega     ||= SecureRandom.random_number(10_000).to_s.rjust(4, "0")
    self.pin_status      ||= "pendente"
    self.tentativas_pin  ||= 0
  end

  def confirmar_entrega!(pin_informado)
    return false if pin_expirado?
    return false if tentativas_pin >= 3

    if pin_entrega == pin_informado
      update!(
        pin_status:       "confirmado",
        entregue_em:      Time.current,
        status:           "concluido",
        status_pagamento: "liberado"
      )
      true
    else
      increment!(:tentativas_pin)
      expirar_pin! if tentativas_pin >= 3
      false
    end
  end

  def expirar_pin!
    update!(pin_status: "expirado")
  end

  # ==========================================================
  # 💰 MONETIZAÇÃO / SPLIT
  # ==========================================================
  def definir_comissao_padrao
    self.comissao_percentual ||= transportador&.respond_to?(:fidelidade?) && transportador.fidelidade? ? 5.0 : 8.0
  end

  def calcular_split!
    base = valor_final || valor_estimado
    return if base.blank?

    self.valor_comissao      = (base * comissao_percentual / 100).round(2)
    self.valor_transportador = (base - valor_comissao).round(2)
  end

  # ==========================================================
  # 💳 VALOR TOTAL (USADO NO PIX)
  # ==========================================================
  def valor_total
    valor_final.presence || valor_estimado.presence || 0
  end
end
