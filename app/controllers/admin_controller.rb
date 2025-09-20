class AdminController < ApplicationController
  before_action :authenticate_admin_master!, only: [:dashboard]

  # Tela de Configurações de Comissão
  def index
    @config = Configuracao.first_or_create(comissao_padrao: 6.0, comissao_assinante: 3.0)
  end

  def update
    @config = Configuracao.first
    if @config.update(params.require(:configuracao).permit(:comissao_padrao, :comissao_assinante))
      redirect_to admin_index_path, notice: "Comissões atualizadas com sucesso!"
    else
      render :index
    end
  end

  # Dashboard Administrativa
  def dashboard
    @fretes = Frete.all
    @clientes = Cliente.all
    @transportadores = Transportador.all
  end

  private

  # Restrição: Apenas admin master acessa a dashboard
  def authenticate_admin_master!
    unless current_cliente&.email == 'admin@cargaclick.com'
      redirect_to root_path, alert: "Acesso restrito."
    end
  end
end
