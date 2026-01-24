# frozen_string_literal: true

class Pagamento < ApplicationRecord
  # =====================================================
  # ASSOCIAÇÕES
  # =====================================================
  belongs_to :frete
  belongs_to :transportador
  belongs_to :cliente, optional: true

  # =====================================================
  # DELEGAÇÕES (views / relatórios)
  # =====================================================
  delegate :descricao, to: :frete, prefix: true, allow_nil: true
  delegate :nome, :email, to: :transportador, prefix: true, allow_nil: true
  delegate :nome, to: :cliente, prefix: true, allow_nil: true

  # =====================================================
  # ALIAS DE COLUNAS (compatibilidade)
  # =====================================================
  alias_attribute :valor_total,         :valor
  alias_attribute :comissao_cargaclick, :comissao

  # =====================================================
  # VALIDAÇÕES
  # =====================================================
  validates :valor_total,
            presence: true,
            numericality: {
              greater_than_or_equal_to: 0,
              less_than: 1_000_000
            }

  validates :status, presence: true

  validates :valor_total, :valor_liquido, :comissao_cargaclick,
            numericality: { greater_than_or_equal_to: 0 },
            allow_nil: true

  # =====================================================
  # STATUS (STRING – FLUXO EFI)
  #
  # Fluxo oficial:
  #   pendente  -> escrow -> liberado
  #
  # Estados auxiliares / compatibilidade:
  #   confirmado, cancelado, estornado
  # =====================================================
  enum status: {
    pendente:   "pendente",
    confirmado: "confirmado", # legado / testes
    escrow:     "escrow",     # dinheiro aprovado e retido
    liberado:   "liberado",   # PIX repassado ao transportador
    cancelado:  "cancelado",
    estornado:  "estornado"
  }, _default: "pendente"

  # =====================================================
  # CALLBACKS
  # =====================================================
  before_validation :set_default_status, on: :create
  before_validation :calcular_totais
  after_update :aplicar_fidelidade_apos_liberacao, if: :saved_change_to_status?

  # =====================================================
  # SCOPES
  # =====================================================
  scope :recentes,   -> { order(created_at: :desc) }
  scope :pendentes,  -> { where(status: "pendente") }
  scope :em_escrow,  -> { where(status: "escrow") }
  scope :liberados,  -> { where(status: "liberado") }
  scope :cancelados, -> { where(status: "cancelado") }
  scope :estornados, -> { where(status: "estornado") }

  # =====================================================
  # HELPERS DE STATUS (views / compatibilidade)
  # =====================================================
  def pendente?
    status == "pendente"
  end

  def pago?
    status == "liberado"
  end

  def erro?
    %w[cancelado estornado].include?(status)
  end

  # =====================================================
  # TRANSIÇÕES DE ESTADO (PROTEGIDAS)
  # =====================================================
  def confirmar!
    raise "Pagamento não está pendente" unless pendente?
    update!(status: "confirmado")
  end

  def colocar_em_escrow!
    raise "Pagamento não pode ir para escrow" unless %w[pendente confirmado].include?(status)

    attrs = { status: "escrow" }
    attrs[:escrow_at] = Time.current if has_attribute?(:escrow_at)
    update!(attrs)
  end

  def liberar!
    raise "Pagamento não está em escrow" unless status == "escrow"

    attrs = { status: "liberado" }
    attrs[:liberado_at] = Time.current if has_attribute?(:liberado_at)
    update!(attrs)
  end

  def cancelar!
    raise "Pagamento já processado" if %w[liberado estornado].include?(status)
    update!(status: "cancelado")
  end

  def estornar!
    raise "Pagamento não pode ser estornado" unless status == "liberado"
    update!(status: "estornado")
  end

  # =====================================================
  # COMISSÃO / CÁLCULOS
  # =====================================================
  def aplicar_comissao!(taxa_percentual)
    taxa_decimal = taxa_percentual.to_d

    self.taxa = taxa_decimal
    self.valor_total = (valor_total.presence || 0).to_d
    self.comissao_cargaclick = (valor_total * taxa_decimal).round(2)
    self.valor_liquido = (valor_total - comissao_cargaclick).round(2)

    save!
  end

  # =====================================================
  # LABELS / DEBUG
  # =====================================================
  def status_label
    I18n.t("pagamentos.status.#{status}", default: status.titleize)
  end

  def to_s
    vt = (valor_total || 0).to_d
    vl = (valor_liquido || 0).to_d

    "💸 Pagamento ##{id} | Frete ##{frete_id} | " \
      "Transportador ##{transportador_id} | #{status_label} | " \
      "Total: R$ #{format('%.2f', vt)} | Líquido: R$ #{format('%.2f', vl)}"
  end

  private

  # =====================================================
  # DEFAULTS / CÁLCULOS INTERNOS
  # =====================================================
  def set_default_status
    self.status ||= "pendente"
  end

  # Não sobrescreve valores vindos do service de pagamento
  def calcular_totais
    base = (valor_total.presence || 0).to_d
    taxa_local = (taxa.presence || 0).to_d
    desconto_local = (desconto.presence || 0).to_d

    self.valor_total = base if valor_total.blank?

    if comissao_cargaclick.blank? && taxa_local.positive?
      self.comissao_cargaclick = (valor_total * taxa_local).round(2)
    end
    self.comissao_cargaclick ||= 0.to_d

    if valor_liquido.blank?
      self.valor_liquido = (valor_total - comissao_cargaclick - desconto_local).round(2)
    end
  end

  # =====================================================
  # FIDELIDADE
  # =====================================================
  def aplicar_fidelidade_apos_liberacao
    _old, new_status = saved_change_to_status
    return unless new_status == "liberado"
    return unless transportador&.respond_to?(:adicionar_pontos!)

    pontos = calcular_pontos_fidelidade
    return if pontos <= 0

    transportador.adicionar_pontos!(pontos)
  rescue StandardError => e
    Rails.logger.error("[Fidelidade] erro no pagamento #{id}: #{e.message}")
  end

  def calcular_pontos_fidelidade
    base = (valor_total.presence || valor_liquido.presence || 0).to_d
    pontos = (base / 10).floor
    [[pontos, 1].max, 100].min
  end
end
