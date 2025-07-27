class AdminController < ApplicationController
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
end
