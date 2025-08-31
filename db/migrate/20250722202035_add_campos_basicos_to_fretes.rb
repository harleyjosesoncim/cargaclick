class AddCamposBasicosToFretes < ActiveRecord::Migration[7.1]
  def change
    add_column :fretes, :descricao, :string unless column_exists?(:fretes, :descricao)
    add_column :fretes, :valor, :decimal, precision: 10, scale: 2 unless column_exists?(:fretes, :valor)
  end
end
