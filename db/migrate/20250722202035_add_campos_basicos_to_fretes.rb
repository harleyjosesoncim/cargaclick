class AddCamposBasicosToFretes < ActiveRecord::Migration[7.1]
  def change
    add_column :fretes, :origem, :string
    add_column :fretes, :destino, :string
    add_column :fretes, :descricao, :text
   end
end
