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

  # Serão preenchidos automaticamente; validamos se presentes
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
  # Calcula totais para que as validações não quebrem e o registro já saia coerente
  before_validation :calcular_totais

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

  # Aplica/atualiza comissão manualmente (ex.: quando taxa vem do painel/admin)
  def aplicar_comissao!(taxa)
    taxa = taxa.to_d
    self.valor_total = (valor.presence || 0).to_d if valor_total.blank?
    self.comissao_cargaclick = (valor_total.to_d * taxa).round(2)
    self.valor_liquido = (valor_total.to_d - comissao_cargaclick.to_d).round(2)
    save!
  end

  # === LABELS ========================================
  def to_s
    vt = (valor_total || 0).to_d
    vl = (valor_liquido || 0).to_d
    "💸 Pagamento ##{id} | Frete ##{frete_id} | Cliente ##{cliente_id} | " \
    "Transportador ##{transportador_id} | #{status_label} | " \
    "Total: R$ #{format('%.2f', vt)} | Líquido: R$ #{format('%.2f', vl)}"
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

  # Calcula/normaliza totais com segurança (usa atributos opcionais se existirem)
  def calcular_totais
    base = (valor.presence || 0).to_d
    taxa = (try(:taxa).presence || 0).to_d          # se existir coluna :taxa
    desc = (try(:desconto).presence || 0).to_d      # se existir coluna :desconto

    self.valor_total = base if valor_total.blank?
    # Só calcula se ainda não houver comissão; mantém se já tiver sido definida
    self.comissao_cargaclick = (valor_total.to_d * taxa).round(2) if comissao_cargaclick.blank?
    self.comissao_cargaclick ||= 0.to_d

    self.valor_liquido = (valor_total.to_d - comissao_cargaclick.to_d - desc).round(2)
  end
end
