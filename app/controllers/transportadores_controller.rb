# frozen_string_literal: true
class TransportadoresController < ApplicationController
  before_action :authenticate_cliente!   # exige login
  before_action :set_transportador, only: [:show, :edit, :update, :destroy]
  before_action :require_admin!, only: [:index, :destroy]
  before_action :authorize_transportador!, only: [:show, :edit, :update]

  def index
    @transportadores = Transportador.order(created_at: :desc)
  end

  def show; end

  def new
    @transportador = Transportador.new
  end

  def create
    @transportador = Transportador.new(transportador_params)
    if @transportador.save
      redirect_to @transportador, notice: "Transportador cadastrado com sucesso."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @transportador.update(transportador_params)
      redirect_to @transportador, notice: "Transportador atualizado."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @transportador.destroy
    redirect_to transportadores_path, notice: "Transportador removido."
  end

  private

  def set_transportador
    @transportador = Transportador.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to transportadores_path, alert: "Transportador não encontrado."
  end

  def transportador_params
    params.require(:transportador).permit(
      :nome, :cpf, :telefone, :email,
      :endereco, :cep, :cidade,
      :tipo_veiculo, :carga_maxima,
      :valor_km, :largura, :altura, :profundidade, :peso_aproximado,
      :pix_key, :mercado_pago_link, :fidelidade_pontos,
      :password, :password_confirmation
    )
  end

  # Só admin pode listar todos ou excluir
  def require_admin!
    admin_email = ENV.fetch("ADMIN_EMAIL", "sac.cargaclick@gmail.com")
    unless current_cliente&.respond_to?(:admin?) && current_cliente.admin? ||
           current_cliente&.email.to_s.casecmp?(admin_email)
      redirect_to root_path, alert: "Acesso restrito ao administrador."
    end
  end

  # Transportador só pode editar/ver o próprio perfil (ou admin)
  def authorize_transportador!
    return if current_cliente&.email.to_s.casecmp?(@transportador.email.to_s)
    return if current_cliente&.respond_to?(:admin?) && current_cliente.admin?

    redirect_to root_path, alert: "Você não tem permissão para acessar este transportador."
  end
end

