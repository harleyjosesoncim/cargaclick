
class SimuladorController < ApplicationController
  require Rails.root.join('lib/open_route_service.rb')

  def new; end

  def create
    origem = params[:origem]
    destino = params[:destino]
    @distancia_km = OpenRouteService.calcular_distancia(origem, destino)

    @ofertas = Transportador.all.map do |t|
      valor_base = @distancia_km * t.custo_por_km.to_f
      taxa = t.fidelidade ? 5 : 8
      valor_total = valor_base * (1 + taxa / 100.0)

      {
        nome: t.nome,
        valor_base: valor_base.round(2),
        taxa: taxa,
        valor_total: valor_total.round(2)
      }
    end.sort_by { |o| o[:valor_total] }

    render :resultado
  end
end
