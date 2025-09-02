# frozen_string_literal: true
class FretesController < ApplicationController
  # Mantém a exigência de login para as mesmas ações e inclui :pagar
  before_action :authenticate_cliente!, only: [:new, :create, :edit, :update, :destroy, :pagar]
  before_action :set_frete, only: [:show, :edit, :update, :destroy, :pagar]
  before_action :authorize_frete!, only: [:edit, :update, :destroy, :pagar]

  # 👉 Redireciona a lista de fretes para o formulário de solicitação (mantido)
  def index
    redirect_to new_frete_path
  end

  def show
    # Show permanece acessível; se quiser restringir a visualização apenas ao dono,
    # troque a linha acima por: authorize_frete!
  end

  def new
    @frete = Frete.new
  end

  def create
    # Constrói sempre a partir do cliente logado, ignorando cliente_id enviado no form
    attrs = normalized_frete_params
    @frete = current_cliente.fretes.build(attrs.except(:cliente_id))

    ActiveRecord::Base.transaction(requires_new: true) do
      if @frete.save
        # Cria a cotação apenas se ainda não existir — evita duplicidade em reenvios/Turbo
        @frete.create_cotacao!(
          cliente_id: current_cliente.id,
          origem:     @frete.cep_origem,
          destino:    @frete.cep_destino,
          peso:       @frete.peso,
          volume:     @frete.volume,
          status:     "pendente"
        ) unless @frete.respond_to?(:cotacao) && @frete.cotacao.present?

        redirect_to @frete, notice: "✅ Solicitação enviada e cotação criada com sucesso."
      else
        render :new, status: :unprocessable_entity
      end
    end
  rescue ActiveRecord::RecordInvalid => e
    Rails.logger.error("[fretes#create] RecordInvalid: #{e.record.class} -> #{e.record.errors.full_messages.join(', ')}")
    flash.now[:alert] = "Erro ao salvar: #{e.record.errors.full_messages.to_sentence}"
    render :new, status: :unprocessable_entity
  rescue StandardError => e
    Rails.logger.error("[fretes#create] #{e.class}: #{e.message}\n#{e.backtrace&.first(5)&.join("\n")}")
    flash.now[:alert] = "Ocorreu um erro inesperado ao criar o frete."
    render :new, status: :unprocessable_entity
  end

  def edit; end

  def update
    attrs = normalized_frete_params

    if @frete.update(attrs.except(:cliente_id))
      redirect_to @frete, notice: "✏️ Frete atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  rescue StandardError => e
    Rails.logger.error("[fretes#update] #{e.class}: #{e.message}")
    flash.now[:alert] = "Erro ao atualizar o frete."
    render :edit, status: :unprocessable_entity
  end

  def destroy
    if @frete.destroy
      redirect_to new_frete_path, notice: "🗑️ Frete removido com sucesso."
    else
      redirect_to @frete, alert: "Erro ao tentar remover o frete."
    end
  end

  # 💳 (Opcional) Pagamento via Mercado Pago — usa o initializer já existente
  def pagar
    sdk = Rails.configuration.x.mercadopago_sdk
    unless sdk
      redirect_to @frete, alert: "Pagamento indisponível no momento (SDK não inicializado)."
      return
    end

    host = ENV["APP_HOST"].presence || request.base_url

    preference_data = {
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
    }

    preference = sdk.preference.create(preference_data)
    init_point = preference.dig("response", "init_point")

    if init_point.present?
      redirect_to init_point, allow_other_host: true
    else
      Rails.logger.error("[fretes#pagar] Preferência sem init_point: #{preference.inspect}")
      redirect_to @frete, alert: "Não foi possível iniciar o checkout."
    end
  rescue StandardError => e
    Rails.logger.error("[fretes#pagar] #{e.class}: #{e.message}")
    redirect_to @frete, alert: "Erro ao iniciar o pagamento."
  end

  private

  # Se o cliente está logado, busca no escopo dele (evita acessar frete de outro cliente)
  # Caso contrário (show público), faz um find global.
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

  # Garante que só o dono edita/atualiza/remove/paga
  def authorize_frete!
    return unless cliente_signed_in?
    return if @frete.cliente_id == current_cliente.id

    redirect_to new_frete_path, alert: "Você não tem permissão para acessar este frete."
  end

  # Mantém os mesmos campos permitidos (sem quebrar forms/botões),
  # mas normaliza números para evitar erros com vírgula.
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

  # Converte "1,75" → 1.75 (BigDecimal), " " ou nil → nil
  def normalize_decimal(value)
    return nil if value.nil? || value.to_s.strip.empty?
    str = value.to_s.tr(",", ".")
    BigDecimal(str)
  rescue ArgumentError
    nil
  end
end
