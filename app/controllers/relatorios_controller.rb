class RelatoriosController < ApplicationController
  def index
  end

  def ganhos
    @fretes_concluidos = Frete.concluido
    @total_ganhos = @fretes_concluidos.sum(:valor_total)
  end

  def avaliacoes
    @avaliacoes = Avaliacao.includes(:frete).order(created_at: :desc)
  end

  def estatisticas
    @qtd_por_status = Frete.group(:status).count
    @media_notas = Avaliacao.average(:nota)
  end
end
