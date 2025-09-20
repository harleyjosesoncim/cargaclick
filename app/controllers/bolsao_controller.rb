class BolsaoController < ApplicationController
  def index
    @fretes = Frete.where(status: 'aberto').includes(:cliente)

    # Filtros (via params do modal)
    @fretes = @fretes.where(cep_origem: params[:cep_origem]) if params[:cep_origem].present?
    @fretes = @fretes.where(cep_destino: params[:cep_destino]) if params[:cep_destino].present?
    if params[:cliente].present?
      @fretes = @fretes.joins(:cliente).where('clientes.nome ILIKE ?', "%#{params[:cliente]}%")
    end
    if params[:peso_min].present?
      @fretes = @fretes.where('peso >= ?', params[:peso_min])
    end
    if params[:peso_max].present?
      @fretes = @fretes.where('peso <= ?', params[:peso_max])
    end
    if params[:valor_min].present?
      @fretes = @fretes.where('valor_estimado >= ?', params[:valor_min])
    end
    if params[:valor_max].present?
      @fretes = @fretes.where('valor_estimado <= ?', params[:valor_max])
    end
  end
end
