class PropostasController < ApplicationController
  def nova
    @frete = Frete.find(params[:frete_id])
    @proposta = Proposta.new
  end

  def create
    @proposta = Proposta.new(proposta_params)
    if @proposta.save
      redirect_to bolsao_path, notice: "Proposta enviada com sucesso!"
    else
      @frete = Frete.find(proposta_params[:frete_id])
      render :nova
    end
  end

  private

  def proposta_params
    params.require(:proposta).permit(:frete_id, :transportador_id, :valor_proposto, :observacao)
  end
end
