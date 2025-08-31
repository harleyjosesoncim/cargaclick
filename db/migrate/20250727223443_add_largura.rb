class AddLargura < ActiveRecord::Migration[7.1]
  def change
    add_column :fretes, :largura, :decimal, precision: 10, scale: 2 unless column_exists?(:fretes, :largura)
  end
end
