class AddClienteNomeToFretes < ActiveRecord::Migration[7.1]
  def change
    add_column :fretes, :cliente_nome, :string
  end
end
