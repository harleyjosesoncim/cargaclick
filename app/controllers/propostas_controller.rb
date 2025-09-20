# app/controllers/propostas_controller.rb
# frozen_string_literal: true

class PropostasController < ApplicationController
  before_action :set_proposta, only: [:show, :gerar_proposta_inteligente]

  def new
    @frete = Frete.find(params[:frete_id]) if params[:frete_id]
    @proposta = Proposta.new(frete: @frete)
  end

  def create
    @proposta = Proposta.new(proposta_params)
    if @proposta.save
      redirect_to @proposta, notice: "Proposta criada com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show; end

  def gerar_proposta_inteligente
    valor_sugerido = @proposta.valor_proposto.to_f * 0.95
    @proposta_inteligente = "Proposta otimizada para frete ##{@proposta.frete_id}, valor sugerido: R$#{valor_sugerido.round(2)}"
    render :proposta_inteligente
  end

  private

  def set_proposta
    @proposta = Proposta.find(params[:id])
  end

  def proposta_params
    params.require(:proposta).permit(:frete_id, :transportador_id, :valor_proposto, :observacao)
  end
end
