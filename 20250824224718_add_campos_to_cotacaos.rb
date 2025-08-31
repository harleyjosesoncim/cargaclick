class AddCamposToCotacoes < ActiveRecord::Migration[7.1]
  def change
    add_column :cotacoes, :origem, :string
    add_column :cotacoes, :destino, :string
    add_column :cotacoes, :peso, :decimal
    add_column :cotacoes, :volume, :decimal
    add_column :cotacoes, :status, :string
  end
end
