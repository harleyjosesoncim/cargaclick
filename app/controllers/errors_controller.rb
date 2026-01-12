# frozen_string_literal: true

class ErrorsController < ApplicationController
  layout false

  def not_found
    render plain: "Página não encontrada", status: :not_found
  end

  def internal_error
    render plain: "Erro interno do servidor", status: :internal_server_error
  end
end
