class AddPagamentosToTransportadores < ActiveRecord::Migration[7.1]
  def change
    add_column :transportadores, :pix_key, :string
    add_column :transportadores, :mercado_pago_link, :string
  end
end
