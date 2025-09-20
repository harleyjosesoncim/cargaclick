class AvaliacoesController < ApplicationController
  before_action :set_frete
  before_action :set_avaliacao, only: [:destroy]

  # POST /fretes/:frete_id/avaliacoes
  def create
    @avaliacao = @frete.avaliacoes.build(avaliacao_params)

    # opcional → associa automaticamente o usuário autenticado
    @avaliacao.cliente = current_cliente if defined?(current_cliente) && current_cliente
    @avaliacao.transportador = current_transportador if defined?(current_transportador) && current_transportador

    if @avaliacao.save
      redirect_to @frete, notice: "Avaliação registrada com sucesso."
    else
      redirect_to @frete, alert: "Erro ao salvar avaliação: #{@avaliacao.errors.full_messages.to_sentence}"
    end
  end

  # DELETE /fretes/:frete_id/avaliacoes/:id
  def destroy
    @avaliacao.destroy
    redirect_to @frete, notice: "Avaliação removida com sucesso."
  end

  private

  def set_frete
    @frete = Frete.find(params[:frete_id])
  end

  def set_avaliacao
    @avaliacao = @frete.avaliacoes.find(params[:id])
  end

  def avaliacao_params
    params.require(:avaliacao).permit(:nota, :comentario)
  end
end
