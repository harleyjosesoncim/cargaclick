# frozen_string_literal: true
class FretesController < ApplicationController
  before_action :authenticate_cliente!, only: [:new, :create, :edit, :update, :destroy]
  before_action :set_frete, only: [:show, :edit, :update, :destroy]

  # 👉 Redireciona a lista de fretes para o formulário de solicitação
  def index
    redirect_to new_frete_path
  end

  def show; end

  def new
    @frete = Frete.new
  end

  def create
    @frete = current_cliente.fretes.build(frete_params)

    ActiveRecord::Base.transaction do
      if @frete.save
        @frete.create_cotacao!(
          cliente_id: current_cliente.id,
          origem: @frete.cep_origem,
          destino: @frete.cep_destino,
          peso: @frete.peso,
          volume: @frete.volume,
          status: "pendente"
        )

        redirect_to @frete, notice: "✅ Solicitação enviada e cotação criada com sucesso."
      else
        render :new, status: :unprocessable_entity
      end
    rescue ActiveRecord::RecordInvalid => e
      flash[:alert] = "Erro ao salvar: #{e.record.errors.full_messages.to_sentence}"
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @frete.update(frete_params)
      redirect_to @frete, notice: "✏️ Frete atualizado com sucesso."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @frete.destroy
      redirect_to new_frete_path, notice: "🗑️ Frete removido com sucesso."
    else
      redirect_to @frete, alert: "Erro ao tentar remover o frete."
    end
  end

  private

  def set_frete
    @frete = Frete.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to new_frete_path, alert: "⚠️ Frete não encontrado."
  end

  def frete_params
    params.require(:frete).permit(
      :cliente_id, :transportador_id,
      :cep_origem, :cep_destino, :descricao,
      :peso, :largura, :altura, :profundidade,
      :valor_estimado, :status
    )
  end
end
