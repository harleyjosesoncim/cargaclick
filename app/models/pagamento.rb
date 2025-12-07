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

  # === ALIAS PARA COLUNAS DO BANCO ==================
  # Banco tem: :valor, :comissao, :taxa, :desconto, :valor_liquido
  # Código usa: :valor_total, :comissao_cargaclick
  alias_attribute :valor_total,        :valor
  alias_attribute :comissao_cargaclick, :comissao

  # === VALIDAÇÕES ===================================
  validates :valor_total,
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
  # Calcula/normaliza totais sem atropelar o que veio do serviço de pagamento
  before_validation :calcular_totais

  # Quando o pagamento for confirmado, aplica pontos de fidelidade
  after_update :aplicar_fidelidade_apos_confirmacao, if: :saved_change_to_status?

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
  def aplicar_comissao!(nova_taxa)
    taxa_decimal = nova_taxa.to_d
    self.taxa = taxa_decimal

    # Usa valor_total (alias de :valor) como base
    self.valor_total = (valor_total.presence || 0).to_d
    self.comissao_cargaclick = (valor_total.to_d * taxa_decimal).round(2)
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

  # === STATUS / DEFAULTS =============================
  def set_default_status
    self.status ||= "pendente"
  end

  # Calcula/normaliza totais com segurança:
  # - não sobrescreve valores já definidos pelo PagamentoPixService
  # - apenas preenche o que estiver em branco
  def calcular_totais
    base = (valor_total.presence || 0).to_d
    taxa_local = (try(:taxa).presence || 0).to_d          # coluna :taxa já existe
    desc = (try(:desconto).presence || 0).to_d            # coluna :desconto já existe

    # Garante que valor_total esteja preenchido (usa base)
    self.valor_total = base if valor_total.blank?

    # Só calcula comissão se ainda não houver valor definido
    if comissao_cargaclick.blank? && taxa_local.positive?
      self.comissao_cargaclick = (valor_total.to_d * taxa_local).round(2)
    end
    self.comissao_cargaclick ||= 0.to_d

    # Só recalcula valor_liquido se ainda estiver em branco
    if valor_liquido.blank?
      self.valor_liquido = (valor_total.to_d - comissao_cargaclick.to_d - desc).round(2)
    end
  end

  # === FIDELIDADE / CLICKPOINTS ======================
  # Quando o status muda para "confirmado", o transportador ganha pontos
  def aplicar_fidelidade_apos_confirmacao
    old_status, new_status = saved_change_to_status
    return unless new_status == "confirmado"
    return unless transportador.present?
    return unless transportador.respond_to?(:adicionar_pontos!)

    pontos = calcular_pontos_fidelidade
    return if pontos <= 0

    transportador.adicionar_pontos!(pontos)
  rescue StandardError => e
    Rails.logger.error("[Fidelidade] erro ao aplicar pontos para transportador #{transportador_id}: #{e.message}")
  end

  # Regra simples: 1 ponto a cada R$ 10 de valor_total, mínimo 1, máximo 100
  def calcular_pontos_fidelidade
    base = (valor_total.presence || valor_liquido.presence || 0).to_d
    pontos = (base / 10).floor
    pontos = 1 if pontos < 1
    pontos = 100 if pontos > 100
    pontos
  end
end
  