class AddWhatsappToClientes < ActiveRecord::Migration[7.1]
  def change
    add_column :clientes, :whatsapp, :string unless column_exists?(:clientes, :whatsapp)
  end
end
