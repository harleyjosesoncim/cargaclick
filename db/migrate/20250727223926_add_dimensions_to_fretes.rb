class AddDimensionsToFretes < ActiveRecord::Migration[7.1]
  def change
    add_column :fretes, :largura, :integer
    add_column :fretes, :altura, :integer
    add_column :fretes, :profundidade, :integer
  end
end
