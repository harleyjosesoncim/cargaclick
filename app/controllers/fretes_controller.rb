# frozen_string_literal: true

class FretesController < ApplicationController
  # =====================================================
  # AUTENTICAÇÃO / AUTORIZAÇÃO
  # =====================================================
  before_action :authenticate_cliente!, except: [:index, :new, :show]
  before_action :set_frete, only: [:show, :edit, :update, :destroy, :pagar]
  before_action :authorize_frete!, only: [:edit, :update, :destroy, :pagar]

  # =====================================================
  # INDEX
  # =====================================================
  # Nunca renderiza lista.
  # Redireciona de forma 100% segura (sem helper quebrar).
  def index
    redirect_to safe_new_frete_path
  end

  # =====================================================
  # SHOW
  # =====================================================
  def show; end

  # =====================================================
  # NEW
  # =====================================================
  def new
    @frete = Frete.new
  end

  # =====================================================
  # CREATE
  # =====================================================
  def create
    attrs = normalized_frete_params

    @frete =
      if cliente_signed_in?
        current_cliente.fretes.build(attrs.except(:cliente_id))
      else
        Frete.new(attrs.except(:cliente_id))
      end

    ActiveRecord::Base.transaction do
      @frete.save!

      if @frete.respond_to?(:cotacao) && @frete.cotacao.blank?
        @frete.create_cotacao!(
          cliente_id: current_cliente&.id,
          origem: @frete.cep_origem,
          destino: @frete.cep_destino,
          peso: @frete.peso,
          volume: @frete.try(:volume),
          status: "pendente"
        )
      end
    end

    redirect_to @frete, notice: "✅ Solicitação enviada com sucesso."

  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("[fretes#create] #{e.record.errors.full_messages.join(', ')}")
    flash.now[:alert] = "Erro ao salvar o frete."
    render :new, status: :unprocessable_entity

  rescue StandardError => e
    Rails.logger.error("[fretes#create] #{e.class}: #{e.message}")
    flash.now[:alert] = "Erro inesperado ao criar o frete."
    render :new, status: :unprocessable_entity
  end

  # =====================================================
  # EDIT / UPDATE
  # =====================================================
  def edit; end

  def update
    if @frete.update(normalized_frete_params.except(:cliente_id))
      redirect_to @frete, notice: "✏️ Frete atualizado com sucesso."
    else
      flash.now[:alert] = "Não foi possível atualizar o frete."
      render :edit, status: :unprocessable_entity
    end
  rescue StandardError => e
    Rails.logger.error("[fretes#update] #{e.class}: #{e.message}")
    flash.now[:alert] = "Erro inesperado ao atualizar o frete."
    render :edit, status: :unprocessable_entity
  end

  # =====================================================
  # DESTROY
  # =====================================================
  def destroy
    @frete.destroy!
    redirect_to safe_new_frete_path, notice: "🗑️ Frete removido com sucesso."
  rescue StandardError => e
    Rails.logger.error("[fretes#destroy] #{e.class}: #{e.message}")
    redirect_to safe_new_frete_path, alert: "Erro ao remover o frete."
  end

  # =====================================================
  # PAGAMENTO
  # =====================================================
  def pagar
    sdk = Rails.configuration.x.mercadopago_sdk

    unless sdk
      redirect_to @frete, alert: "Pagamento indisponível no momento."
      return
    end

    host = ENV["APP_HOST"].presence || request.base_url

    preference = sdk.preference.create(
      items: [{
        title: "Frete CargaClick",
        quantity: 1,
        currency_id: "BRL",
        unit_price: (@frete.valor_estimado || 0).to_f
      }],
      back_urls: {
        success: "#{host}/pagamento/sucesso",
        failure: "#{host}/pagamento/falha",
        pending: "#{host}/pagamento/pendente"
      },
      auto_return: "approved",
      statement_descriptor: "CARGACLICK"
    )

    init_point = preference.dig("response", "init_point")

    if init_point.present?
      redirect_to init_point, allow_other_host: true
    else
      Rails.logger.error("[fretes#pagar] init_point ausente")
      redirect_to @frete, alert: "Não foi possível iniciar o pagamento."
    end

  rescue StandardError => e
    Rails.logger.error("[fretes#pagar] #{e.class}: #{e.message}")
    redirect_to @frete, alert: "Erro ao iniciar o pagamento."
  end

  # =====================================================
  # PRIVATES
  # =====================================================
  private

  # 🔒 BUSCA SEGURA
  def set_frete
    @frete =
      if cliente_signed_in?
        current_cliente.fretes.find(params[:id])
      else
        Frete.find(params[:id])
      end
  rescue ActiveRecord::RecordNotFound
    redirect_to safe_new_frete_path, alert: "⚠️ Frete não encontrado."
  end

  # 🔒 AUTORIZAÇÃO
  def authorize_frete!
    return unless cliente_signed_in?
    return if @frete.cliente_id == current_cliente.id

    redirect_to safe_new_frete_path, alert: "Você não tem permissão para este frete."
  end

  # =====================================================
  # 🔥 MÉTODO CRÍTICO — NUNCA QUEBRA
  # =====================================================
  def safe_new_frete_path
    respond_to?(:new_frete_path) ? new_frete_path : "/fretes/new"
  end

  # PARAMS
  def frete_params
    params.require(:frete).permit(
      :cliente_id, :transportador_id,
      :cep_origem, :cep_destino, :descricao,
      :peso, :largura, :altura, :profundidade,
      :valor_estimado, :status
    )
  end

  def normalized_frete_params
    p = frete_params.to_h.symbolize_keys
    %i[peso largura altura profundidade valor_estimado].each do |k|
      p[k] = normalize_decimal(p[k]) if p.key?(k)
    end
    p
  end

  def normalize_decimal(value)
    return nil if value.blank?
    BigDecimal(value.to_s.tr(",", "."))
  rescue ArgumentError
    nil
  end
end
