# frozen_string_literal: true

module CadastroGuard
  extend ActiveSupport::Concern

  included do
    before_action :verificar_cadastro_completo
  end

  private

  def verificar_cadastro_completo
    # 🔒 NUNCA bloqueia telas do Devise
    return if devise_controller?

    # 🔒 Só aplica se houver usuário logado
    return unless current_cliente || current_transportador

    usuario = current_cliente || current_transportador

    # 🔒 Só aplica se o método existir
    return unless usuario.respond_to?(:status_cadastro)

    # status_cadastro: basico / completo
    if usuario.status_cadastro == "basico"
      redirect_to completar_cadastro_path_for(usuario),
                  alert: "🚀 Complete seu cadastro para liberar todas as funcionalidades."
    end
  end

  def completar_cadastro_path_for(usuario)
    if usuario.is_a?(Cliente)
      completar_cadastro_cliente_path
    else
      completar_perfil_transportador_path
    end
  end
end

