class CotacoesController < ApplicationController
  before_action :authenticate_cliente!   # exige login
  before_action :set_cotacao, only: [:show, :edit, :update, :destroy]

  # GET /cotacoes
  def index
    # mostra apenas as cotações do cliente logado
    @cotacoes = current_cliente.cotacoes.includes(:frete).order(created_at: :desc)
  end

  # GET /cotacoes/:id
  def show
  end

  # GET /cotacoes/:id/edit
  def edit
  end

  # PATCH/PUT /cotacoes/:id
  def update
    if @cotacao.update(cotacao_params)
      redirect_to cotacoes_path, notice: "Cotação atualizada com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /cotacoes/:id
  def destroy
    @cotacao.destroy
    redirect_to cotacoes_path, notice: "Cotação removida com sucesso."
  end

  private

  def set_cotacao
    # segurança: só permite acessar se a cotação pertencer ao cliente logado
    @cotacao = current_cliente.cotacoes.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to cotacoes_path, alert: "Cotação não encontrada ou não pertence a você."
  end

  def cotacao_params
    params.require(:cotacao).permit(:valor, :status, :observacoes)
  end
end
