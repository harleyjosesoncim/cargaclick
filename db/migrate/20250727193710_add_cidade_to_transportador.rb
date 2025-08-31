class AddCidadeToTransportador < ActiveRecord::Migration[7.1]
  def change
    add_column :transportadores, :cidade, :string unless column_exists?(:transportadores, :cidade)
  end
end
