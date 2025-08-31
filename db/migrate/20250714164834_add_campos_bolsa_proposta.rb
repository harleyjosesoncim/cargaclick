class AddCamposBolsaProposta < ActiveRecord::Migration[7.1]
  def change
    add_column :propostas, :bolsa, :decimal, precision: 10, scale: 2 unless column_exists?(:propostas, :bolsa)
  end
end
