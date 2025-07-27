class RankingController < ApplicationController
  def index
    @top_transportadores = Transportador.all.sort_by { |t| -t.fretes.where(entregue: true).count }.first(10)
  end
end
