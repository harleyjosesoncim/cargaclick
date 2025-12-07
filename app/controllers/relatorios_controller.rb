# app/controllers/relatorios_controller.rb
class RelatoriosController < ApplicationController
  before_action :set_periodo, only: %i[ganhos avaliacoes estatisticas]

  def index; end

  # /relatorios/ganhos?from=2025-01-01&to=2025-12-31
  def ganhos
    scope = Pagamento.confirmados.includes(:frete, :transportador, :cliente)
    scope = scope.where(created_at: @from..@to) if @from && @to

    @pagamentos = scope.order(created_at: :desc)

    # Total movimentado em fretes (o que o cliente paga)
    @total_movimentado = scope.sum(Arel.sql("COALESCE(valor, 0)"))

    # Total repassado aos transportadores
    @total_repassado_transportadores = scope.sum(Arel.sql("COALESCE(valor_liquido, 0)"))

    # Ganho da plataforma (comissão CargaClick)
    @total_ganhos_plataforma = scope.sum(Arel.sql("COALESCE(comissao, 0)"))
  end

  # /relatorios/avaliacoes?from=2025-01-01&to=2025-12-31
  def avaliacoes
    scope = Avaliacao.includes(:frete)
    scope = scope.where(created_at: @from..@to) if @from && @to

    @avaliacoes  = scope.order(created_at: :desc)
    @media_notas = scope.average(:nota).to_f.round(2)
  end

  # /relatorios/estatisticas?from=2025-01-01&to=2025-12-31
  def estatisticas
    scope = Frete.all
    scope = scope.where(created_at: @from..@to) if @from && @to

    raw_counts       = scope.group(:status).count
    @qtd_por_status  = ordenar_status(raw_counts)
    @media_notas     = if @from && @to
                         Avaliacao.where(created_at: @from..@to).average(:nota).to_f.round(2)
                       else
                         Avaliacao.average(:nota).to_f.round(2)
                       end
  end

  private

  # Aceita params[:from], params[:to] (YYYY-MM-DD ou data/hora); default = últimos 30 dias
  def set_periodo
    @from = parse_datetime(params[:from]) || 30.days.ago.beginning_of_day
    @to   = parse_datetime(params[:to])   || Time.current.end_of_day
  end

  def parse_datetime(v)
    return if v.blank?
    Time.zone.parse(v) rescue nil
  end

  # Se houver enum em Frete.statuses, devolve contagem em ordem dos statuses definidos.
  def ordenar_status(raw)
    return raw unless Frete.respond_to?(:statuses)

    ordered = {}
    Frete.statuses.keys.each { |k| ordered[k] = raw[k] || 0 }
    raw.each { |k, v| ordered[k] ||= v } # inclui chaves “extras”, se houver
    ordered
  end
end
