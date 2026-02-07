# app/controllers/fretes_controller.rb
class FretesController < ApplicationController
  before_action :set_frete, only: %i[
    show edit update destroy chat rastreamento contratar
  ]

  # ==================================================
  # FORMULÁRIO PÚBLICO (SIMULAÇÃO)
  # ==================================================
  def new
    # form público → não depende de model
  end

  # ==================================================
  # SIMULAÇÃO DE FRETE (PÚBLICO - NÃO SALVA)
  # ==================================================
  def simular
    parametros_simulacao = {
      origem:       params[:origem].to_s.strip,
      destino:      params[:destino].to_s.strip,
      peso:         params[:peso].presence,
      volume:       params[:volume].presence,
      tipo_veiculo: params[:tipo_veiculo],
      tipo_carga:   params[:tipo_carga]
    }

    if parametros_simulacao[:origem].blank? || parametros_simulacao[:destino].blank?
      flash[:alert] = "Informe origem e destino para simular o frete."
      redirect_to simular_frete_path
      return
    end

    resultado = CalcularFrete.call(parametros_simulacao)

    if resultado[:sucesso]
      @resultado = resultado
      render :resultado, status: :ok
    else
      Rails.logger.warn(
        "[FretesController#simular] #{resultado[:mensagem]} | #{resultado[:detalhes]}"
      )
      flash[:alert] = resultado[:mensagem] || "Não foi possível simular o frete."
      redirect_to simular_frete_path
    end

  rescue StandardError => e
    Rails.logger.error(
      "[FretesController#simular][FATAL] #{e.class}: #{e.message}"
    )
    render "errors/500", status: :internal_server_error
  end

  # ==================================================
  # CONTRATAÇÃO REAL DO FRETE (CLIENTE OBRIGATÓRIO)
  # ==================================================
  def create
    authenticate_cliente!

    @frete = Frete.new(frete_params)
    @frete.cliente = current_cliente

    if @frete.save
      redirect_to @frete, notice: "Frete contratado com sucesso."
    else
      Rails.logger.warn(
        "[FretesController#create] #{@frete.errors.full_messages.join(', ')}"
      )
      flash.now[:alert] = "Não foi possível contratar o frete."
      render :new, status: :unprocessable_entity
    end
  end

  # ==================================================
  # CRUD
  # ==================================================
  def show; end
  def edit; end

  def update
    if @frete.update(frete_params)
      redirect_to @frete, notice: "Frete atualizado com sucesso."
    else
      flash.now[:alert] = "Erro ao atualizar o frete."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @frete.destroy
    redirect_to inicio_path, notice: "Frete removido."
  end

  # ==================================================
  # FUNCIONALIDADES EXTRAS
  # ==================================================
  def chat; end
  def rastreamento; end

  private

  # ==================================================
  # BUSCA SEGURA (ANTI-500)
  # ==================================================
  def set_frete
    @frete = Frete.find_by(id: params[:id])
    return if @frete.present?

    redirect_to inicio_path, alert: "Frete não encontrado."
  end

  # ==================================================
  # STRONG PARAMS
  # ==================================================
  def frete_params
    params.require(:frete).permit(
      :origem,
      :destino,
      :peso,
      :volume,
      :tipo_carga,
      :tipo_veiculo,
      :descricao,
      :valor
    )
  end
end
