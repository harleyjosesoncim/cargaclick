class AddPinStatusToFretes < ActiveRecord::Migration[7.1]
  def change
    add_column :fretes, :pin_status, :string, default: "pendente", null: false
    add_index  :fretes, :pin_status
  end
end

