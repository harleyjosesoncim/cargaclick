# frozen_string_literal: true

class TransportadoresController < ApplicationController
  # =====================================================
  # SEGURANÇA
  # =====================================================

  protect_from_forgery except: :optin

  # Transportador precisa estar autenticado
  before_action :authenticate_transportador!,
                except: %i[cadastro optin]

  # Apenas admin pode listar ou excluir
  before_action :require_admin!, only: %i[index destroy]

  # Carrega transportador quando necessário
  before_action :set_transportador,
                only: %i[show edit update destroy]

  # Transportador comum só acessa o próprio registro
  before_action :authorize_transportador!,
                only: %i[show edit update]

  # Completar perfil (Pix + CEP)
  before_action :authenticate_transportador!,
                only: %i[completar_perfil atualizar_perfil]

  # =====================================================
  # AÇÕES PÚBLICAS
  # =====================================================

  # GET /transportadores/cadastro
  def cadastro
    @transportador = Transportador.new
  end

  # POST /api/transportadores/optin
  # Cadastro via Discord / API (LGPD)
  def optin
    return consentimento_invalido unless consentimento_valido?

    transportador = build_transportador

    if transportador.save
      render json: sucesso(transportador), status: :created
    else
      render json: erro_validacao(transportador), status: :unprocessable_entity
    end
  rescue StandardError => e
    Rails.logger.error "[OPTIN TRANSPORTADOR] #{e.class} - #{e.message}"
    render json: erro_interno, status: :internal_server_error
  end

  # =====================================================
  # AÇÕES PRIVADAS (LOGADO)
  # =====================================================

  # ADMIN
  def index
    @transportadores = Transportador.order(created_at: :desc)
  end

  # PAINEL BÁSICO
  def show; end

  def edit; end

  def update
    if @transportador.update(transportador_params)
      redirect_to transportador_path(@transportador),
                  notice: "Dados atualizados com sucesso."
    else
      flash.now[:alert] = "Não foi possível atualizar os dados."
      render :edit, status: :unprocessable_entity
    end
  end

  # =====================================================
  # COMPLETAR PERFIL (PIX + CEP)
  # =====================================================

  # GET /transportadores/completar_perfil
  def completar_perfil
    # apenas renderiza a view
  end

  # PATCH /transportadores/atualizar_perfil
  def atualizar_perfil
    if current_transportador.update(transportador_perfil_params)
      redirect_to transportador_path(current_transportador),
                  notice: "Perfil atualizado com sucesso."
    else
      flash.now[:alert] = "Não foi possível salvar. Verifique os dados."
      render :completar_perfil, status: :unprocessable_entity
    end
  end

  # =====================================================
  # ADMIN
  # =====================================================

  def destroy
    @transportador.destroy
    redirect_to root_path, notice: "Transportador removido com sucesso."
  end

  # =====================================================
  # MÉTODOS PRIVADOS
  # =====================================================
  private

  # ---------- LGPD ----------
  def consentimento_valido?
    params[:consentimento].to_s == "on"
  end

  def consentimento_invalido
    render json: {
      success: false,
      error: "Consentimento obrigatório (LGPD)"
    }, status: :unprocessable_entity
  end

  # ---------- BUILD ----------
  def build_transportador
    Transportador.new(
      nome: params[:nome],
      telefone: params[:telefone],
      email: params[:email],
      cidade: params[:cidade],
      tipo_veiculo: params[:tipo_veiculo],
      capacidade: params[:capacidade],
      origem: params[:origem].presence || "discord",
      status: "pendente"
    )
  end

  # ---------- PARAMS ----------
  def transportador_params
    params.require(:transportador).permit(
      :nome, :email, :telefone, :whatsapp,
      :cidade, :cep,
      :cpf, :cnpj,
      :tipo_veiculo, :capacidade,
      :valor_km, :valor_fixo,
      :observacoes,
      :password, :password_confirmation
    )
  end

  def transportador_perfil_params
    params.require(:transportador).permit(
      :cep,
      :pix_type,
      :pix_key
    )
  end

  # ---------- LOAD ----------
  def set_transportador
    @transportador = Transportador.find_by(id: params[:id])
    return if @transportador

    redirect_to root_path, alert: "Transportador não encontrado."
  end

  # ---------- AUTH ----------
  def authorize_transportador!
    return if current_transportador == @transportador
    return if current_transportador&.admin?

    redirect_to root_path, alert: "Acesso não autorizado."
  end

  def require_admin!
    return if current_transportador&.admin?

    admin_email = ENV.fetch("ADMIN_EMAIL", "sac.cargaclick@gmail.com")
    return if current_transportador&.email&.casecmp?(admin_email)

    redirect_to root_path, alert: "Acesso restrito ao administrador."
  end

  # ---------- RESPONSES ----------
  def sucesso(transportador)
    {
      success: true,
      id: transportador.id,
      status: transportador.status,
      message: "Cadastro realizado com sucesso"
    }
  end

  def erro_validacao(transportador)
    {
      success: false,
      error: "Erro de validação",
      details: transportador.errors.full_messages
    }
  end

  def erro_interno
    {
      success: false,
      error: "Erro interno ao processar cadastro"
    }
  end
end
