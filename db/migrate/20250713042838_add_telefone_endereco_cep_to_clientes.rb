class AddTelefoneEnderecoCepToClientes < ActiveRecord::Migration[7.1]
  def change
    unless column_exists? :clientes, :telefone
      add_column :clientes, :telefone, :string
    end
    unless column_exists? :clientes, :endereco
      add_column :clientes, :endereco, :string
    end
    unless column_exists? :clientes, :cep
      add_column :clientes, :cep, :string
    end
  end
end
