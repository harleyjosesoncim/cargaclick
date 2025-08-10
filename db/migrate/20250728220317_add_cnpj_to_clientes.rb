class AddCnpjToClientes < ActiveRecord::Migration[7.1]
  def change
    add_column :clientes, :cnpj, :string
  end
end
