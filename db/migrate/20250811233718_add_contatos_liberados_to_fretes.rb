class AddContatosLiberadosToFretes < ActiveRecord::Migration[7.1]
  def change
    add_column :fretes, :contatos_liberados, :boolean, default: false unless column_exists?(:fretes, :contatos_liberados)
  end
end
