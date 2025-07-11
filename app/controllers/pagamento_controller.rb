
class PagamentoController < ApplicationController
  def show
    @frete = Frete.find(params[:id])
    @transportador = @frete.transportador
  end
end
