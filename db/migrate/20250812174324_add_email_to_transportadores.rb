class AddEmailToTransportadores < ActiveRecord::Migration[7.1]
  def change
    add_column :transportadores, :email, :string
    add_index :transportadores, :email
  end
end
