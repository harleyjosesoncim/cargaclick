# frozen_string_literal: true

module CadastroGuard
  extend ActiveSupport::Concern

  private

  def exigir_cadastro_completo!(usuario, redirect_path:, mensagem:)
    return if usuario&.completo?

    redirect_to redirect_path, alert: mensagem
  end
end
