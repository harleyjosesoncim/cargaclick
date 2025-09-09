class RenamePixKeyToChavePixInTransportadores < ActiveRecord::Migration[6.1]
  def change
    rename_column :transportadores, :pix_key, :chave_pix
  end
end
