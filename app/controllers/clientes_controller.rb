# frozen_string_literal: true

class ClientesController < ApplicationController
  # =====================================================
  # AUTENTICAÇÃO E AUTORIZAÇÃO
  # =====================================================

  # Cliente precisa estar logado para qualquer ação privada
  before_action :authenticate_cliente!, except: %i[new create]

  # Apenas admin pode listar ou excluir clientes
  before_action :require_admin!, only: %i[index destroy]

  # Carrega cliente apenas quando necessário
  before_action :set_cliente, only: %i[show edit update destroy]

  # Cliente comum só pode acessar o próprio registro
  before_action :authorize_cliente!, only: %i[show edit update]

  # =====================================================
  # AÇÕES
  # =====================================================

  # ADMIN – lista completa
  def index
    @clientes = Cliente.order(created_at: :desc)
  end

  # DASHBOARD DO CLIENTE (PERMANENTE)
  def show
    # render padrão
  end

  # CADASTRO (CLIENTE ESPORÁDICO → PERMANENTE)
  def new
    @cliente = Cliente.new
  end

  def create
    @cliente = Cliente.new(cliente_params)

    if @cliente.save
      sign_in(@cliente) if respond_to?(:sign_in)

      redirect_to cliente_path(@cliente),
                  notice: "Cadastro realizado com sucesso."
    else
      flash.now[:alert] = "Não foi possível concluir o cadastro."
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    # render padrão
  end

  def update
    if @cliente.update(cliente_params)
      redirect_to cliente_path(@cliente),
                  notice: "Dados atualizados com sucesso."
    else
      flash.now[:alert] = "Não foi possível atualizar os dados."
      render :edit, status: :unprocessable_entity
    end
  end

  # ADMIN
  def destroy
    @cliente.destroy
    redirect_to root_path, notice: "Cliente removido com sucesso."
  end

  # =====================================================
  # MÉTODOS PRIVADOS
  # =====================================================
  private

  # Carrega cliente com fallback seguro
  def set_cliente
    @cliente = Cliente.find_by(id: params[:id])

    return if @cliente

    redirect_to root_path, alert: "Cliente não encontrado."
  end

  # Strong params
  def cliente_params
    params.require(:cliente).permit(
      :nome, :email, :telefone, :whatsapp,
      :endereco, :cep,
      :cpf, :cnpj, :tipo,
      :largura, :altura, :profundidade, :peso_aproximado,
      :observacoes,
      :password, :password_confirmation
    )
  end

  # ADMIN CHECK (isolado e seguro)
  def require_admin!
    return if current_cliente&.admin?

    admin_email = ENV.fetch("ADMIN_EMAIL", "sac.cargaclick@gmail.com")
    return if current_cliente&.email&.casecmp?(admin_email)

    redirect_to root_path, alert: "Acesso restrito ao administrador."
  end

  # AUTORIZAÇÃO DO CLIENTE
  def authorize_cliente!
    return if current_cliente == @cliente
    return if current_cliente&.admin?

    redirect_to root_path, alert: "Você não tem permissão para acessar esta área."
  end
end
