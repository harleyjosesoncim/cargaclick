class AddCampoToClientes < ActiveRecord::Migration[7.1]
  def change
    add_column :clientes, :campo_extra, :string unless column_exists?(:clientes, :campo_extra)
  end
end
