class AddDeviseToClientes < ActiveRecord::Migration[7.1]
  def change
    change_table :clientes do |t|
      t.string :encrypted_password, null: false, default: "" unless column_exists?(:clientes, :encrypted_password)
    end
  end
end
