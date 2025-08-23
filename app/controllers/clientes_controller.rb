# app/controllers/clientes_controller.rb
# frozen_string_literal: true

class ClientesController < ApplicationController
  before_action :authenticate_cliente!
  before_action :require_admin!

  before_action :normalize_query
  before_action :set_pagination

  def index
    # Evita NameError se o modelo ainda não existir no ambiente
    unless defined?(Cliente) && Cliente < ActiveRecord::Base
      @clientes = []
      @pager    = empty_pager
      return
    end

    scope = Cliente.all

    # Busca case-insensitive com escape seguro
    if @q.present?
      q    = ActiveRecord::Base.sanitize_sql_like(@q)
      like = "%#{q}%"
      if postgres?
        scope = scope.where("email ILIKE :q OR COALESCE(nome,'') ILIKE :q", q: like)
      else
        scope = scope.where("LOWER(email) LIKE LOWER(:q) OR LOWER(COALESCE(nome,'')) LIKE LOWER(:q)", q: like)
      end
    end

    scope     = scope.order(created_at: :desc)
    @total    = scope.count
    @clientes = scope.limit(@per).offset((@page - 1) * @per)

    @pager = {
      page:        @page,
      per:         @per,
      total:       @total,
      total_pages: (@total.to_f / @per).ceil,
      has_next:    (@page * @per) < @total
    }

    respond_to do |format|
      format.html
      format.json { render json: { clientes: @clientes.as_json(only: %i[id email nome created_at]), pager: @pager } }
    end
  rescue ActiveRecord::StatementInvalid, ActiveRecord::NoDatabaseError => e
    Rails.logger.error("[clientes#index] #{e.class}: #{e.message}")
    @clientes = []
    @pager    = empty_pager
    flash.now[:alert] = "Não foi possível consultar os clientes no momento."
    render :index, status: :ok
  end

  private

  # ---- Acesso ----
  def require_admin!
    # 1) Preferencialmente use uma coluna/flag admin no modelo
    return if current_cliente&.respond_to?(:admin?) && current_cliente.admin?

    # 2) Fallback por e-mail do admin via ENV
    admin_email = ENV.fetch("ADMIN_EMAIL", "sac.cargaclick@gmail.com")
    return if current_cliente&.email.to_s.casecmp?(admin_email)

    redirect_to(authenticated_root_path, alert: "Acesso restrito ao admin.")
  end

  # ---- Busca / Paginação ----
  def normalize_query
    @q = params[:q].to_s.strip
  end

  def set_pagination
    @page = params[:page].to_i
    @per  = params[:per].to_i
    @page = 1   if @page < 1
    @per  = 20  if @per <= 0
    @per  = 100 if @per > 100
  end

  def empty_pager
    { page: @page, per: @per, total: 0, total_pages: 0, has_next: false }
  end

  # ---- Util ----
  def postgres?
    ActiveRecord::Base.connection.adapter_name.downcase.include?("postgres")
  rescue StandardError
    false
  end
end
