# app/controllers/contatos_controller.rb
class ContatosController < ApplicationController
  def new
    @contato = Contato.new
  end

  def create
    @contato = Contato.new(contato_params)
    if @contato.save
      redirect_to root_path, notice: "Mensagem enviada com sucesso!"
    else
      flash.now[:alert] = "Erro ao enviar mensagem."
      render :new, status: :unprocessable_entity
    end
  end

  private

  def contato_params
    params.require(:contato).permit(:nome, :email, :mensagem)
  end
end
