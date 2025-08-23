class AddEntregueToFretes < ActiveRecord::Migration[7.1]
  def up
    unless column_exists?(:fretes, :entregue)
      add_column :fretes, :entregue, :boolean, default: false
    end
  end

  def down
    if column_exists?(:fretes, :entregue)
      remove_column :fretes, :entregue
    end
  end
end


