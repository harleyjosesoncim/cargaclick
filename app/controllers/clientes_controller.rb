class ClientesController < ApplicationController
  before_action :authenticate_cliente!
  before_action :require_admin! # somente admin vê a listagem de clientes

  def index
    @q    = params[:q].to_s.strip
    page  = params.fetch(:page, 1).to_i
    per   = params.fetch(:per, 20).to_i
    page  = 1 if page < 1
    per   = 20 if per <= 0
    per   = 100 if per > 100

    scope = defined?(Cliente) ? Cliente.all : []

    if scope.respond_to?(:where) && @q.present?
      like  = "%#{@q}%"
      scope = scope.where("LOWER(email) LIKE LOWER(?) OR LOWER(nome) LIKE LOWER(?)", like, like)
    end

    if scope.respond_to?(:order)
      scope = scope.order(created_at: :desc)
      @clientes = scope.limit(per).offset((page - 1) * per)
    else
      @clientes = []
    end

    @pager = { page: page, per: per, has_next: @clientes.size == per }
  end

  private

  def require_admin!
    admin_email = ENV.fetch("ADMIN_EMAIL", "sac.cargaclick@gmail.com")
    ok = respond_to?(:current_cliente) && current_cliente&.email&.casecmp?(admin_email)
    redirect_to(root_path, alert: "Acesso restrito ao admin.") unless ok
  end
end