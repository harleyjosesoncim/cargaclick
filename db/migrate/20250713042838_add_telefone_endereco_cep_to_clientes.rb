class AddTelefoneEnderecoCepToClientes < ActiveRecord::Migration[7.1]
  def change
    add_column :clientes, :telefone, :string
    add_column :clientes, :endereco, :string
    add_column :clientes, :cep, :string
  end
end
