class AddPagamentosToTransportadores < ActiveRecord::Migration[7.1]
  def change
    add_column :transportadores, :pix_key, :string unless column_exists?(:transportadores, :pix_key)
    add_column :transportadores, :mercado_pago_link, :string unless column_exists?(:transportadores, :mercado_pago_link)
  end
end
