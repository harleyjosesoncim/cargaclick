# app/controllers/clientes_controller.rb
class ClientesController < ApplicationController
  # O filtro before_action garante que o método set_cliente seja chamado
  # antes das ações show, edit, update e destroy. Isso evita duplicação de código.
  before_action :set_cliente, only: [:show, :edit, :update, :destroy]

  # GET /clientes
  # Exibe uma lista de todos os clientes.
  def index
    @clientes = Cliente.all # Busca todos os clientes do banco de dados.
  end

  # GET /clientes/:id
  # Exibe os detalhes de um cliente específico.
  def show
    # @cliente já é definido pelo before_action :set_cliente
  end

  # GET /clientes/new
  # Inicializa um novo objeto cliente para o formulário de criação.
  def new
    @cliente = Cliente.new # Cria uma nova instância de Cliente, ainda não salva.
  end

  # GET /clientes/:id/edit
  # Prepara o formulário para edição de um cliente existente.
  def edit
    # @cliente já é definido pelo before_action :set_cliente
  end

  # POST /clientes
  # Cria um novo cliente com os parâmetros enviados.
  def create
    @cliente = Cliente.new(cliente_params) # Instancia com os parâmetros permitidos.

    if @cliente.save # Tenta salvar o novo cliente no banco de dados.
      redirect_to @cliente, notice: "Cliente criado com sucesso." # Redireciona para a página de exibição com uma mensagem de sucesso.
    else
      render :new, status: :unprocessable_entity # Se a gravação falhar, renderiza novamente o formulário 'new' com erros.
    end
  end
  def cliente_params
  params.require(:cliente).permit(:nome, :cpf, :cnpj, :telefone, :endereco, :cep, :email)
end

def gerar_proposta_ai(cliente)
  prompt = "Crie uma proposta comercial profissional para a empresa #{cliente.empresa}, convidando-a a utilizar a plataforma CargaClick para contratar serviços de frete de forma econômica e rápida. Destaque as vantagens competitivas."
  resposta = OpenaiService.new(prompt).call

  HistoricoProposta.create!(conteudo: resposta)
end

  # GET /clientes/:id/gerar_proposta
  # PATCH/PUT /clientes/:id
  # Atualiza um cliente existente com os parâmetros enviados.
  def update
    if @cliente.update(cliente_params) # Tenta atualizar o cliente com os parâmetros permitidos.
      redirect_to @cliente, notice: "Cliente atualizado com sucesso." # Redireciona para a página de exibição com uma mensagem de sucesso.
    else
      render :edit, status: :unprocessable_entity # Se a atualização falhar, renderiza novamente o formulário 'edit' com erros.
    end
  end

  # DELETE /clientes/:id
  # Exclui um cliente específico do banco de dados.
  def destroy
    @cliente.destroy # Exclui o cliente.
    redirect_to clientes_url, notice: "Cliente excluído com sucesso." # Redireciona para a página de índice com uma mensagem de sucesso.
  end

  private

  # set_cliente é um método privado usado pelo filtro before_action.
  # Ele encontra um Cliente pelo seu ID e o atribui a @cliente.
  def set_cliente
    @cliente = Cliente.find(params[:id]) # Encontra o cliente pelo ID a partir dos parâmetros da URL.
  end

  # cliente_params é um método privado que define quais parâmetros são permitidos
  # para atribuição em massa ao modelo Cliente. Esta é uma medida de segurança.
  def cliente_params
    params.require(:cliente).permit(:nome, :cpf, :telefone, :endereco, :cep, :email) # Requer :cliente e permite atributos específicos.
  end
end
