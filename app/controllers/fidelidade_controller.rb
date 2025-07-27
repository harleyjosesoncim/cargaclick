class FidelidadeController < ApplicationController
  def cliente
    @cliente = Cliente.find(params[:id])
    # Pontos baseados em quantidade de fretes realizados
    @pontos = @cliente.fretes.count * 10
  end

  def transportador
    @transportador = Transportador.find(params[:id])
    # Pontos baseados em entregas com sucesso
    @pontos = @transportador.fretes.where(entregue: true).count * 15
  end
end
