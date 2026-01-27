class AddValoresToFretes < ActiveRecord::Migration[7.1]
  def change
    add_column :fretes, :valor, :decimal, precision: 10, scale: 2 unless column_exists?(:fretes, :valor)
    add_column :fretes, :valor_negociado, :decimal, precision: 10, scale: 2 unless column_exists?(:fretes, :valor_negociado)
    add_column :fretes, :valor_final, :decimal, precision: 10, scale: 2 unless column_exists?(:fretes, :valor_final)
  end
end
