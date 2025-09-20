class AddCnpjToClientes < ActiveRecord::Migration[7.1]
  def change
    add_column :clientes, :cnpj, :string, limit: 14 unless column_exists?(:clientes, :cnpj)
  end
end
