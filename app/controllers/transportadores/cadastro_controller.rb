# frozen_string_literal: true

class Transportadores::CadastroController < ApplicationController
  before_action :authenticate_transportador!

  def edit
    @transportador = current_transportador
  end

  def update
    @transportador = current_transportador

    if @transportador.update(transportador_params.merge(status_cadastro: :completo))
      redirect_to transportadores_dashboard_path,
                  notice: "Perfil concluído com sucesso!"
    else
      flash.now[:alert] = "Por favor, revise os dados obrigatórios."
      render :edit
    end
  end

  private

  def transportador_params
    params.require(:transportador).permit(
      :cpf,
      :tipo_documento,
      :documento,
      :cnh_numero,
      :placa_veiculo,
      :tipo_veiculo,
      :carga_maxima,
      :valor_km,
      :cidade,
      :endereco,
      :cep,
      :chave_pix,
      :pix_key,
      :mercado_pago_link
    )
  end
end
