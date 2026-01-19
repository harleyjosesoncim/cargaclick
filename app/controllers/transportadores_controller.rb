# frozen_string_literal: true

class TransportadoresController < ApplicationController
  # =====================================================
  # SEGURANÇA / AUTENTICAÇÃO
  # =====================================================

  # Opt-in via API não usa CSRF (Discord / bots / integrações)
  protect_from_forgery except: :optin

  # Devise – transportador precisa estar logado
  before_action :authenticate_transportador!,
                except: %i[cadastro optin]

  # Apenas admin pode listar e excluir
  before_action :require_admin!,
                only: %i[index destroy]

  # Carrega registro quando necessário
  before_action :set_transportador,
                only: %i[show edit update destroy]

  # Transportador comum só pode acessar o próprio registro
  before_action :authorize_transportador!,
                only: %i[show edit update]

  # =====================================================
  # AÇÕES PÚBLICAS
  # =====================================================

  # GET /transportadores/cadastro
  def cadastro
    @transportador = Transportador.new
  end

  # POST /api/transportadores/optin
  # Cadastro simplificado via API / Discord (LGPD)
  def optin
    return render_consentimento_invalido unless consentimento_valido?

    transportador = build_transportador

    if transportador.save
      render json: resposta_sucesso(transportador), status: :created
    else
      render json: resposta_erro_validacao(transportador),
             status: :unprocessable_entity
    end
  rescue StandardError => e
    Rails.logger.error("[TransportadoresController#optin] #{e.class}: #{e.message}")
    render json: resposta_erro_interno, status: :internal_server_error
  end

  # =====================================================
  # AÇÕES PRIVADAS (LOGADO)
  # =====================================================

  # ADMIN
  def index
    @transportadores = Transportador.order(created_at: :desc)
  end

  # PAINEL
  def show; end

  def edit; end

  def update
    if @transportador.update(transportador_params)
      redirect_to @transportador,
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
    @transportador = current_transportador
  end

  # PATCH /transportadores/atualizar_perfil
  def atualizar_perfil
    @transportador = current_transportador

    if @transportador.update(transportador_perfil_params)
      redirect_to @transportador,
                  notice: "Perfil atualizado com sucesso."
    else
      flash.now[:alert] = "Erro ao salvar perfil. Verifique os dados."
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

  # -----------------------------------------------------
  # LGPD
  # -----------------------------------------------------
  def consentimento_valido?
    params[:consentimento].to_s == "on"
  end

  def render_consentimento_invalido
    render json: {
      success: false,
      error: "Consentimento obrigatório conforme LGPD"
    }, status: :unprocessable_entity
  end

  # -----------------------------------------------------
  # BUILD (OPT-IN)
  # -----------------------------------------------------
  def build_transportador
    Transportador.new(
      nome:         params[:nome],
      email:        params[:email],
      telefone:     params[:telefone],
      cidade:       params[:cidade],
      tipo_veiculo: params[:tipo_veiculo],
      capacidade:   params[:capacidade],
      origem:       params[:origem].presence || "optin_api",
      status:       "pendente"
    )
  end

  # -----------------------------------------------------
  # STRONG PARAMS
  # -----------------------------------------------------
  def transportador_params
    params.require(:transportador).permit(
      :nome,
      :email,
      :telefone,
      :whatsapp,
      :cidade,
      :cep,
      :cpf,
      :cnpj,
      :tipo_veiculo,
      :capacidade,
      :valor_km,
      :valor_fixo,
      :observacoes,
      :password,
      :password_confirmation
    )
  end

  def transportador_perfil_params
    params.require(:transportador).permit(
      :cep,
      :pix_type,
      :pix_key
    )
  end

  # -----------------------------------------------------
  # LOAD
  # -----------------------------------------------------
  def set_transportador
    @transportador = Transportador.find_by(id: params[:id])
    return if @transportador.present?

    redirect_to root_path, alert: "Transportador não encontrado."
  end

  # -----------------------------------------------------
  # AUTORIZAÇÃO
  # -----------------------------------------------------
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

  # -----------------------------------------------------
  # RESPONSES (API)
  # -----------------------------------------------------
  def resposta_sucesso(transportador)
    {
      success: true,
      id: transportador.id,
      status: transportador.status,
      message: "Cadastro realizado com sucesso"
    }
  end

  def resposta_erro_validacao(transportador)
    {
      success: false,
      error: "Erro de validação",
      details: transportador.errors.full_messages
    }
  end

  def resposta_erro_interno
    {
      success: false,
      error: "Erro interno ao processar solicitação"
    }
  end
end
