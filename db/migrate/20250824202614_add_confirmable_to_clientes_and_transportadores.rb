class AddConfirmableToClientesAndTransportadores < ActiveRecord::Migration[7.1]
  def change
    add_column :clientes, :confirmation_token, :string unless column_exists?(:clientes, :confirmation_token)
    add_column :transportadores, :confirmation_token, :string unless column_exists?(:transportadores, :confirmation_token)
  end
end
