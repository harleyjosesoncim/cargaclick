# frozen_string_literal: true

class ClientesController < ApplicationController
  # === BEFORE ACTIONS ===================================
  before_action :authenticate_cliente!, except: [:new, :create]
  before_action :require_admin!, only: [:index, :destroy]
  before_action :set_cliente, only: [:show, :edit, :update, :destroy]
  before_action :authorize_cliente!, only: [:show, :edit, :update]

  # === AÇÕES PÚBLICAS ===================================
  def index
    @clientes = Cliente.order(created_at: :desc)
  end

  def show; end

  def new
    @cliente = Cliente.new
  end

  def create
    @cliente = Cliente.new(cliente_params)
    if @cliente.save
      redirect_to @cliente, notice: "Cliente criado com sucesso."
    else
      flash.now[:alert] = "Não foi possível criar o cliente."
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @cliente.update(cliente_params)
      redirect_to @cliente, notice: "Cliente atualizado com sucesso."
    else
      flash.now[:alert] = "Não foi possível atualizar o cliente."
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @cliente.destroy
    redirect_to clientes_path, notice: "Cliente removido com sucesso."
  end

  # === PRIVADOS =========================================
  private

  def set_cliente
    @cliente = Cliente.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to clientes_path, alert: "Cliente não encontrado."
  end

  def cliente_params
    params.require(:cliente).permit(
      :nome, :email, :telefone, :whatsapp,
      :endereco, :cep,
      :cpf, :cnpj, :tipo,
      :largura, :altura, :profundidade, :peso_aproximado,
      :observacoes, :campo,
      :password, :password_confirmation
    )
  end

  # Apenas admin pode ver lista completa ou excluir
  def require_admin!
    admin_email = ENV.fetch("ADMIN_EMAIL", "sac.cargaclick@gmail.com")
    unless current_cliente&.admin? || current_cliente&.email&.casecmp?(admin_email)
      redirect_to root_path, alert: "Acesso restrito ao administrador."
    end
  end

  # Garante que cliente só veja/edite o próprio perfil, a não ser que seja admin
  def authorize_cliente!
    return if current_cliente == @cliente
    return if current_cliente&.admin?

    redirect_to root_path, alert: "Você não tem permissão para acessar este cliente."
  end
end
