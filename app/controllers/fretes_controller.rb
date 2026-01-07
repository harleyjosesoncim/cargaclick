class FretesController < ApplicationController
  # Mesmo que a rota 'index' esteja redirecionando no routes.rb,
  # manter o método aqui evita erros se você decidir mudar a rota no futuro.
  def index
    redirect_to new_frete_path
  end

  def new
    @frete = Frete.new
  end

  def create
    @frete = Frete.new(frete_params)
    if @frete.save
      # Redireciona para o checkout/pagamento após criar
      redirect_to pagar_frete_path(@frete)
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @frete = Frete.find(params[:id])
  end

  def pagar
    @frete = Frete.find(params[:id])
    # Lógica de integração (Mercado Pago, etc)
  end

  private

  def frete_params
    # Ajuste os campos conforme seu banco de dados
    params.require(:frete).permit(:origem, :destino, :peso, :comprimento, :altura, :largura)
  end
end