# app/controllers/clientes_controller.rb
class ClientesController < ApplicationController
  # GET /clientes/new
  # Ação para exibir o formulário de novo cliente.
  # Esta ação inicializa um novo objeto Cliente para ser usado no formulário.
  def new
    @cliente = Cliente.new # <--- ESSENCIAL: Inicializa @cliente para evitar NoMethodError
  end

  # POST /clientes
  # Ação para criar um novo cliente a partir dos dados submetidos pelo formulário.
  def create
    @cliente = Cliente.new(cliente_params) # Cria um novo objeto Cliente com os parâmetros permitidos.

    if @cliente.save # Tenta salvar o cliente no banco de dados.
      # Se o salvamento for bem-sucedido, redireciona o usuário para a lista de clientes
      # e exibe uma mensagem de sucesso.
      redirect_to clientes_path, notice: 'Cliente cadastrado com sucesso!'
    else
      # Se houver erros de validação (por exemplo, campos obrigatórios vazios),
      # re-renderiza o formulário 'new' para que os erros possam ser exibidos ao usuário.
      # O objeto @cliente já conterá as mensagens de erro neste ponto.
      render :new, status: :unprocessable_entity
    end
  end # <--- FIM do método 'create'

  # GET /clientes
  # Ação para listar todos os clientes.
  # Esta é uma ação comum para exibir uma tabela ou lista de todos os clientes existentes.
  def index
    @clientes = Cliente.all
  end

  private

  # Método privado para Strong Parameters.
  # Isso garante que apenas os atributos permitidos (:nome, :email) possam ser
  # atribuídos em massa ao objeto Cliente, prevenindo vulnerabilidades de segurança.
  def cliente_params
    params.require(:cliente).permit(:nome, :email)
  end
end # <--- FIM da classe 'ClientesController'
