# app/controllers/fretes_controller.rb
class FretesController < ApplicationController
  before_action :set_frete, only: %i[show edit update destroy chat rastreamento]

  # ============================
  # SIMULAÇÃO / CRIAÇÃO (PÚBLICO)
  # ============================
  def new
    @frete = Frete.new
  end

  def create
    @frete = Frete.new(frete_params)

    # offline-safe: cálculo local, se existir
    if @frete.respond_to?(:calcular_valor) && @frete.valor.blank?
      begin
        @frete.valor = @frete.calcular_valor
      rescue StandardError => e
        Rails.logger.warn("[FretesController] Falha no cálculo do valor: #{e.message}")
      end
    end

    if @frete.save
      redirect_to @frete, notice: "Frete criado com sucesso."
    else
      flash.now[:alert] = "Não foi possível criar o frete."
      render :new, status: :unprocessable_entity
    end
  end

  # ============================
  # VISUALIZAÇÃO / EDIÇÃO
  # ============================
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

  # ============================
  # REMOÇÃO
  # ============================
  def destroy
    @frete.destroy
    redirect_to inicio_path, notice: "Frete removido."
  end

  # ============================
  # FUNCIONALIDADES EXTRAS
  # ============================
  def chat; end

  def rastreamento
    # offline-safe: view faz fallback sem Leaflet/CDN
  end

  private

  # ============================
  # BUSCA SEGURA (ANTI-500)
  # ============================
  def set_frete
    @frete = Frete.find_by(id: params[:id])

    return if @frete.present?

    redirect_to inicio_path, alert: "Frete não encontrado."
  end

  # ============================
  # STRONG PARAMS DEFENSIVO
  # ============================
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
