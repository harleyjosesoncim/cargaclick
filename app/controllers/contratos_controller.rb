
class ContratosController < ApplicationController
  before_action :set_contrato

  def show; end

  def aceitar
    @contrato.aceitar!(
      ip: request.remote_ip,
      user_agent: request.user_agent
    )
    redirect_to checkout_pagamento_path(@contrato.frete),
      notice: "Contrato aceito com sucesso."
  end

  private

  def set_contrato
    @contrato = ContratoDigital.find(params[:id])
  end
end
