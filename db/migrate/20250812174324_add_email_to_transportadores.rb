class AddEmailToTransportadores < ActiveRecord::Migration[7.1]
  def change
    add_column :transportadores, :email, :string unless column_exists?(:transportadores, :email)
  end
end
