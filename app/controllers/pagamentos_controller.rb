class PagamentosController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[webhook ping]

  def checkout
    result = PagamentoPixService.new.checkout(params[:frete_id])
    if result.success?
      render json: result.data
    else
      render json: { error: result.error }, status: :unprocessable_entity
    end
  end

  def retorno
    PagamentoPixService.new.retorno(params)
    redirect_to root_path, notice: "Pagamento processado. Se aprovado, os contatos foram liberados."
  end

  def webhook
    PagamentoPixService.new.webhook(params)
    head :ok
  end

  def ping
    head :ok
  end
end

