# app/models/pagamento.rb
# frozen_string_literal: true

class Pagamento < ApplicationRecord
  # === ASSOCIAÇÕES ==================================
  belongs_to :frete
  belongs_to :transportador
  belongs_to :cliente, optional: true # Pode ser PF, PJ ou avulso

  # Delegações para exibir dados sem precisar chamar objetos manualmente
  delegate :descricao, to: :frete, prefix: true, allow_nil: true
  delegate :nome, :email, to: :transportador, prefix: true, allow_nil: true
  delegate :nome, to: :cliente, prefix: true, allow_nil: true

  # === VALIDAÇÕES ===================================
  validates :valor,
            presence: true,
            numericality: {
              greater_than_or_equal_to: 0,
              less_than: 1_000_000
            }

  validates :status, presence: true

  validates :valor_total, :valor_liquido, :comissao_cargaclick,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  # === STATUS ========================================
  enum status: {
    pendente:   "pendente",
    confirmado: "confirmado",
    cancelado:  "cancelado"
  }, _default: "pendente"

  # === CALLBACKS =====================================
  before_validation :set_default_status, on: :create

  # === SCOPES ========================================
  scope :recentes,    -> { order(created_at: :desc) }
  scope :pendentes,   -> { where(status: "pendente") }
  scope :confirmados, -> { where(status: "confirmado") }
  scope :cancelados,  -> { where(status: "cancelado") }

  # === LÓGICA DE NEGÓCIO =============================
  def confirmar!
    update!(status: "confirmado")
  end

  def cancelar!
    update!(status: "cancelado")
  end

  def pendente?
    status == "pendente"
  end

  def aplicar_comissao!(taxa)
    self.valor_total ||= valor
    self.comissao_cargaclick = (valor_total * taxa).round(2)
    self.valor_liquido = valor_total - comissao_cargaclick
    save!
  end

  # === LABELS ========================================
  def to_s
    "💸 Pagamento ##{id} | Frete ##{frete_id} | Cliente ##{cliente_id} | " \
    "Transportador ##{transportador_id} | #{status_label} | " \
    "Total: R$ #{'%.2f' % valor_total} | Líquido: R$ #{'%.2f' % valor_liquido}"
  end

  def status_label
    I18n.t("pagamentos.status.#{status}", default: status.titleize)
  end

  # === BOTÕES (para views) ===========================
  def checkout_button(view_context)
    return unless pendente?

    view_context.button_to(
      "Pagar com Mercado Pago",
      view_context.checkout_pagamentos_path(frete_id: frete_id), # ✅ alinhado com controller
      method: :post,
      class: "bg-blue-600 text-white px-4 py-2 rounded-lg shadow hover:bg-blue-700"
    )
  end

  def cancelar_button(view_context)
    return unless pendente?

    view_context.button_to(
      "Cancelar Pagamento",
      view_context.cancelar_pagamento_path(self), # usa rota member definida no routes.rb
      method: :patch,
      class: "bg-red-600 text-white px-4 py-2 rounded-lg shadow hover:bg-red-700",
      data: { confirm: "Tem certeza que deseja cancelar este pagamento?" }
    )
  end

  private

  def set_default_status
    self.status ||= "pendente"
  end
end
