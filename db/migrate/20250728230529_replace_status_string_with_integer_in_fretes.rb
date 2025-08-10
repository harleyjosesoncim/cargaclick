class ReplaceStatusStringWithIntegerInFretes < ActiveRecord::Migration[7.1]
  def change
    remove_column :fretes, :status, :string
    add_column :fretes, :status, :integer, default: 0
  end
end
