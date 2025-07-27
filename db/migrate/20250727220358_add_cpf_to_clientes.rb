class AddCpfToClientes < ActiveRecord::Migration[7.1]
  def change
    add_column :clientes, :cpf, :string
  end
end
