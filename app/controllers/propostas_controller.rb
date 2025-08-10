class PropostasController < ApplicationController
  before_action :set_proposta, only: [:show, :edit, :update, :destroy, :gerar_proposta_inteligente]

  def index
    @propostas = Proposta.all
  end

  def show
  end

  def new
    @proposta = Proposta.new
  end

  def edit
  end

  def create
    @proposta = Proposta.new(proposta_params)
    if @proposta.save
      redirect_to @proposta, notice: 'Proposta criada com sucesso.'
    else
      render :new
    end
  end

  def update
    if @proposta.update(proposta_params)
      redirect_to @proposta, notice: 'Proposta atualizada com sucesso.'
    else
      render :edit
    end
  end

  def destroy
    @proposta.destroy
    redirect_to propostas_url, notice: 'Proposta excluída com sucesso.'
  end

  def gerar_proposta_inteligente
    frete = @proposta.frete

    prompt = <<~PROMPT
      Crie uma proposta profissional de transporte com as seguintes informações:
      - Origem: #{frete.origem}
      - Destino: #{frete.destino}
      - Tipo de Carga: #{frete.descricao}
      - Peso: #{frete.peso} kg
      - Transportador: #{@proposta.transportador.nome}
      - Valor Proposto: R$ #{@proposta.valor_proposto}

      O tom deve ser profissional, persuasivo e objetivo.
    PROMPT

    @proposta_inteligente = GptService.generate_content(prompt)

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

