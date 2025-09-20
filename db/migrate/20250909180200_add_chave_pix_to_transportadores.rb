class AddChavePixToTransportadores < ActiveRecord::Migration[6.1]
  def change
    add_column :transportadores, :chave_pix, :string
  end
end
