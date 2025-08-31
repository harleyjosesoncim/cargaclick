class AdjustStatusInFretes < ActiveRecord::Migration[7.1]
  def change
    change_column :fretes, :status, :integer, default: 0 if column_exists?(:fretes, :status)
  end
end
