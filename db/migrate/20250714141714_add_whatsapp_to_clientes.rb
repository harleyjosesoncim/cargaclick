class AddWhatsappToClientes < ActiveRecord::Migration[7.1]
  def change
    add_column :clientes, :whatsapp, :string
  end
end
