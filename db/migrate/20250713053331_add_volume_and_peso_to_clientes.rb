class AddVolumeAndPesoToClientes < ActiveRecord::Migration[7.1]
  def change
    add_column :clientes, :largura, :float
    add_column :clientes, :altura, :float
    add_column :clientes, :profundidade, :float
    add_column :clientes, :peso_aproximado, :float
  end
end
