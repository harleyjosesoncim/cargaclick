# app/controllers/fretes_controller.rb
class FretesController < ApplicationController
  before_action :set_frete, only: %i[show edit update destroy chat rastreamento]

  # ==================================================
  # FORMULÁRIO PÚBLICO (CRIAÇÃO)
  # ==================================================
  def new
    @frete = Frete.new
  end

  def create
    @frete = Frete.new(frete_params)

    # Cálculo local defensivo (NUNCA quebra fluxo)
    if @frete.respond_to?(:calcular_valor) && @frete.valor.blank?
      begin
        @frete.valor = @frete.calcular_valor
      rescue StandardError => e
        Rails.logger.warn("[FretesController#create] Cálculo local falhou: #{e.message}")
      end
    end

    if @frete.save
      redirect_to @frete, notice: "Frete criado com sucesso."
    else
      flash.now[:alert] = "Não foi possível criar o frete."
      render :new, status: :unprocessable_entity
    end
  end

  # ==================================================
  # SIMULAÇÃO DE FRETE (PÚBLICO)
  # ==================================================
  def simular
    parametros_simulacao = {
      origem: params[:origem],
      destino: params[:destino],
      peso: params[:peso],
      tipo_veiculo: params[:tipo_veiculo]
    }

    resultado = CalcularFrete.call(parametros_simulacao)

    if resultado[:sucesso]
      @resultado = resultado
      render :simular, status: :ok
    else
      Rails.logger.warn(
        "[FretesController#simular] Falha: #{resultado[:mensagem]} | #{resultado[:detalhes]}"
      )
      flash.now[:alert] = resultado[:mensagem] || "Não foi possível simular o frete."
      render :simular, status: :unprocessable_entity
    end
  rescue StandardError => e
    Rails.logger.error(
      "[FretesController#simular][FATAL] #{e.class}: #{e.message}\n#{e.backtrace&.first(5)&.join("\n")}"
    )
    render "errors/500", status: :internal_server_error
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
    params.fetch(:frete, {}).permit(
      :origem,
      :destino,
      :peso,
      :volume,
      :tipo_carga,
      :tipo_veiculo,
      :descricao,
      :valor,
      :status
    )
  end
end
