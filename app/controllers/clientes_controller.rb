# app/controllers/clientes_controller.rb
class ClientesController < ApplicationController
  def index
    # teste de fumaça: não toca no banco
    return render plain: "ok /clientes (controller carregado)" if ENV["CLIENTES_SMOKE"] == "true"

    # código normal (só roda quando tirar o SMOKE)
    @clientes = defined?(Cliente) ? Cliente.order(created_at: :desc).limit(50) : []
  end
end
