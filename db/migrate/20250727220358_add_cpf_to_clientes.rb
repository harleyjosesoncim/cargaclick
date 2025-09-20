class AddCpfToClientes < ActiveRecord::Migration[7.1]
  def change
    add_column :clientes, :cpf, :string, limit: 11 unless column_exists?(:clientes, :cpf)
  end
end
