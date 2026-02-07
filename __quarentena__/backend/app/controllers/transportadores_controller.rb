class TransportadoresController < ApplicationController
  protect_from_forgery except: :optin

  def optin
    unless params[:consentimento] == "on"
      return render json: { error: "Consentimento obrigatório (LGPD)" }, status: 422
    end

    transportador = Transportador.create!(
      nome: params[:nome],
      telefone: params[:telefone],
      email: params[:email],
      cidade: params[:cidade],
      tipo_veiculo: params[:tipo_veiculo],
      capacidade: params[:capacidade],
      origem: params[:origem] || "discord",
      status: "pendente"
    )

    render json: { success: true, id: transportador.id }
  end
end
