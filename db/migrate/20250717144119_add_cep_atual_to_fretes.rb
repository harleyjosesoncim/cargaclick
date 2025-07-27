class AddCepAtualToFretes < ActiveRecord::Migration[7.1]
  def change
    add_column :fretes, :cep_atual, :string
  end
end
