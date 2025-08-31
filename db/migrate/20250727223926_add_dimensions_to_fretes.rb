class AddDimensionsToFretes < ActiveRecord::Migration[7.1]
  def change
    add_column :fretes, :altura, :decimal, precision: 10, scale: 2 unless column_exists?(:fretes, :altura)
    add_column :fretes, :profundidade, :decimal, precision: 10, scale: 2 unless column_exists?(:fretes, :profundidade)
  end
end
