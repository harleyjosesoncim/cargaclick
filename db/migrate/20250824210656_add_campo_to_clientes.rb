class AddCampoToClientes < ActiveRecord::Migration[7.1]
  def change
    add_column :clientes, :campo, :string
  end
end
