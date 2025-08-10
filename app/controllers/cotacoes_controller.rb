class CotacoesController < ApplicationController
  before_action :set_cotacao, only: [:show, :edit, :update, :destroy]

  # GET /cotacoes
  def index
    @cotacoes = Cotacao.all
  end

  # GET /cotacoes/1
  def show
  end

  # GET /cotacoes/new
  def new
    @cotacao = Cotacao.new
  end

  # GET /cotacoes/1/edit
  def edit
  end

  # POST /cotacoes
  def create
    @cotacao = Cotacao.new(cotacao_params)

    if @cotacao.save
      redirect_to @cotacao, notice: 'Cotação criada com sucesso.'
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /cotacoes/1
  def update
    if @cotacao.update(cotacao_params)
      redirect_to @cotacao, notice: 'Cotação atualizada com sucesso.', status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /cotacoes/1
  def destroy
    @cotacao.destroy!
    redirect_to cotacoes_url, notice: 'Cotação apagada com sucesso.', status: :see_other
  end

  private

    # Callback para carregar a cotação pelo ID
    def set_cotacao
      @cotacao = Cotacao.find(params[:id])
    end

    # Parâmetros permitidos para criação/edição de cotações
    def cotacao_params
      params.require(:cotacao).permit(:cliente_id, :origem, :destino, :peso, :volume, :status)
    end
end

