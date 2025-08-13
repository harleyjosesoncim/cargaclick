class AddContatosLiberadosToFretes < ActiveRecord::Migration[7.1]
  def change
    add_column :fretes, :contatos_liberados, :boolean
  end
end
