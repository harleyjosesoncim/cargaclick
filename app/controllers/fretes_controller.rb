# frozen_string_literal: true

class FretesController < ApplicationController
  # =====================================================
  # AUTENTICAÇÃO / AUTORIZAÇÃO
  # =====================================================
  # Mantém login apenas onde é realmente necessário.
  # Isso evita erro 500 ao renderizar a home ou rotas públicas.
  before_action :authenticate_cliente!, except: [:index, :new, :show]
  before_action :set_frete, only: [:show, :edit, :update, :destroy, :pagar]
  before_action :authorize_frete!, only: [:edit, :update, :destroy, :pagar]

  # =====================================================
  # INDEX
  # =====================================================
  # Nunca renderiza lista — sempre direciona ao fluxo principal.
  # Blindado para nunca gerar 500.
  def index
    redirect_to new_frete_path
  end

  # =====================================================
  # SHOW
  # =====================================================
  # Público para visualização básica.
  # Se quiser restringir no futuro, basta exigir autenticação aqui.
  def show; end

  # =====================================================
  # NEW
  # =====================================================
  # Deve funcionar mesmo sem login (evita quebra da Home).
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

    ActiveRecord::Base.transaction(requires_new: true) do
      @frete.save!

      # Criação idempotente da cotação (se existir associação)
      if @frete.respond_to?(:cotacao) && @frete.cotacao.blank?
        @frete.create_cotacao!(
          cliente_id: current_cliente&.id,
          origem:     @frete.cep_origem,
          destino:    @frete.cep_destino,
          peso:       @frete.peso,
          volume:     @frete.try(:volume),
          status:     "pendente"
        )
      end
    end

    redirect_to @frete, notice: "✅ Solicitação enviada com sucesso."

  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("[fretes#create] RecordInvalid: #{e.record.errors.full_messages.join(', ')}")
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
    redirect_to new_frete_path, notice: "🗑️ Frete removido com sucesso."
  rescue StandardError => e
    Rails.logger.error("[fretes#destroy] #{e.class}: #{e.message}")
    redirect_to new_frete_path, alert: "Erro ao remover o frete."
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
      items: [
        {
          title: "Frete CargaClick",
          quantity: 1,
          currency_id: "BRL",
          unit_price: (@frete.valor_estimado || 0).to_f
        }
      ],
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

  def set_frete
    @frete =
      if cliente_signed_in?
        current_cliente.fretes.find(params[:id])
      else
        Frete.find(params[:id])
      end
  rescue ActiveRecord::RecordNotFound
    redirect_to new_frete_path, alert: "⚠️ Frete não encontrado."
  end

  def authorize_frete!
    return unless cliente_signed_in?
    return if @frete.cliente_id == current_cliente.id
