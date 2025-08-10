class PagamentoController < ApplicationController
  before_action :set_frete
  before_action :authorize_cliente!

  # GET /pagamento/:id
  def show
    @transportador = @frete.transportador
    unless @transportador
      redirect_to fretes_path, alert: "Transportador não encontrado para este frete."
    end
  end

  private

    def set_frete
      @frete = Frete.find_by(id: params[:id])
      unless @frete
        redirect_to fretes_path, alert: "Frete não encontrado."
      end
    end

    def authorize_cliente!
      if @frete.cliente != current_cliente
        redirect_to fretes_path, alert: "Acesso não autorizado."
      end
    end
end

