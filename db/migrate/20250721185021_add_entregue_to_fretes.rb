class AddEntregueToFretes < ActiveRecord::Migration[7.1]
  def change
    add_column :fretes, :entregue, :boolean
    add_column :fretes, :entregue, :boolean, default: false
  end
end
