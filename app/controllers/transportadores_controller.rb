class TransportadoresController < ApplicationController
  # Público: lista de transportadores (landing). Coloque authenticate_cliente! se quiser restringir.
  def index
    @q    = params[:q].to_s.strip
    page  = params.fetch(:page, 1).to_i
    per   = params.fetch(:per, 20).to_i
    page  = 1 if page < 1
    per   = 20 if per <= 0
    per   = 100 if per > 100

    scope = defined?(Transportador) ? Transportador.all : []

    if scope.respond_to?(:where) && @q.present?
      like  = "%#{@q}%"
      # tenta por nome/veículo/cidade, se as colunas existirem
      if scope.column_names.include?("nome") || scope.column_names.include?("name")
        scope = scope.where("LOWER(nome) LIKE LOWER(?)", like) if scope.column_names.include?("nome")
        scope = scope.or(Transportador.where("LOWER(name) LIKE LOWER(?)", like)) if scope.column_names.include?("name")
      end
      scope = scope.where("LOWER(tipo_veiculo) LIKE LOWER(?)", like) if scope.column_names.include?("tipo_veiculo")
      scope = scope.where("LOWER(cidade) LIKE LOWER(?)", like) if scope.column_names.include?("cidade")
    end

    if scope.respond_to?(:order)
      scope = scope.order(created_at: :desc)
      @transportadores = scope.limit(per).offset((page - 1) * per)
    else
      @transportadores = []
    end

    @pager = { page: page, per: per, has_next: @transportadores.size == per }
  end
end