# app/controllers/fretes_controller.rb
class FretesController < ApplicationController
  before_action :set_frete, only: %i[show edit update destroy chat rastreamento]

  # ============================
  # SIMULAÇÃO / CRIAÇÃO (PÚBLICO)
  # ============================

  # Formulário público
  def new
    @frete = Frete.new
  end

  # Criação real do frete
  def create
    @frete = Frete.new(frete_params)

    # Cálculo offline-safe (não pode quebrar)
    if @frete.respond_to?(:calcular_valor) && @frete.valor.blank?
      begin
        @frete.valor = @frete.calcular_valor
      rescue StandardError => e
        Rails.logger.warn("[FretesController#create] Falha no cálculo local: #{e.message}")
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
  # SIMULAÇÃO DE FRETE (PÚBLICO)
  # ============================

  def simular
    resultado = CalcularFrete.call(params)

    if resultado[:sucesso]
      @resultado = resultado
      render :simular
    else
      Rails.logger.warn("[FretesController#simular] #{resultado[:erro]}")
      flash[:alert] = resultado[:mensagem] || "Não foi possível simular o frete."
      redirect_to simular_frete_path
    end
  rescue StandardError => e
    Rails.logger.error("[FretesController#simular][500] #{e.class}: #{e.message}")
    redirect_to inicio_path, alert: "Erro interno ao simular frete."
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

  def chat
    # preparado para Action Cable
  end

  def rastreamento
    # offline-safe: view deve ter fallback sem JS/CDN
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
