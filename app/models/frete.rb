# frozen_string_literal: true

class Frete < ApplicationRecord
  # ==========================================================
  # 📎 ASSOCIAÇÕES
  # ==========================================================
  belongs_to :cliente
  belongs_to :transportador, optional: true

  has_many :avaliacoes, dependent: :destroy
  has_one  :cotacao, dependent: :destroy

  # ==========================================================
  # 🎛️ ENUMS (ALINHADOS AO BANCO)
  # ==========================================================

  # Coluna: status (string)
  enum status: {
    pendente:     "pendente",
    aceito:       "aceito",
    em_andamento: "em_andamento",
    concluido:    "concluido",
    cancelado:    "cancelado"
  }, _prefix: :frete

  # 🔴 COLUNA INTEGER — CAUSA DO ERRO 500 (AGORA CORRIGIDA)
  enum status_pagamento: {
    pendente:  0,
    pago:      1,
    liberado:  2,
    cancelado: 3
  }, _prefix: :pagamento

  # Coluna: pin_status (string)
  enum pin_status: {
    pendente:   "pendente",
    confirmado: "confirmado",
    expirado:   "expirado"
  }, _prefix: :pin

  # ==========================================================
  # ✅ VALIDAÇÕES (PRODUÇÃO)
  # ==========================================================
  validates :status, :status_pagamento, :pin_status, presence: true
  validates :tentativas_pin, numericality: { greater_than_or_equal_to: 0 }

  # ==========================================================
  # 🔄 CALLBACKS (CONTROLADOS)
  # ==========================================================
  before_validation :definir_defaults, on: :create
  before_save       :calcular_split!, if: :base_para_split_presente?

  # ==========================================================
  # 🔐 PIN DE ENTREGA
  # ==========================================================
  def confirmar_entrega!(pin_informado)
    return false if pin_expirado? || tentativas_pin >= 3
    return false if pin_informado.blank?

    if pin_entrega == pin_informado.to_s
      update!(
        pin_status:       :confirmado,
        status:           :concluido,
        status_pagamento: :liberado,
        entregue_em:      Time.current
      )
      true
    else
      incrementar_tentativa!
      false
    end
  end

  def expirar_pin!
    update!(pin_status: :expirado)
  end

  # ==========================================================
  # 💰 MONETIZAÇÃO / SPLIT
  # ==========================================================
  def valor_total
    base_para_split
  end

  # ==========================================================
  # 🔒 MÉTODOS PRIVADOS
  # ==========================================================
  private

  # ---------- Defaults seguros ----------
  def definir_defaults
    self.pin_entrega        ||= gerar_pin
    self.pin_status         ||= "pendente"
    self.status             ||= "pendente"
    self.status_pagamento   ||= 0 # integer
    self.tentativas_pin     ||= 0
    self.comissao_percentual ||= comissao_padrao
  end

  def gerar_pin
    SecureRandom.random_number(10_000).to_s.rjust(4, "0")
  end

  # ---------- PIN ----------
  def incrementar_tentativa!
    increment!(:tentativas_pin)
    expirar_pin! if tentativas_pin >= 3
  end

  # ---------- Comissão ----------
  def comissao_padrao
    transportador&.respond_to?(:fidelidade?) && transportador.fidelidade? ? 5.0 : 8.0
  end

  # ---------- Split ----------
  def calcular_split!
    base = base_para_split
    return if base.zero? || comissao_percentual.blank?

    self.valor_comissao      = (base * comissao_percentual / 100).round(2)
    self.valor_transportador = (base - valor_comissao).round(2)
  end

  def base_para_split
    valor_final.presence || valor_estimado.presence || 0
  end

  def base_para_split_presente?
    valor_final.present? || valor_estimado.present?
  end
end
