class AddDocumentoAndMotoFieldsToTransportadores < ActiveRecord::Migration[7.1]
  def change
    add_column :transportadores, :tipo_documento, :string
    add_column :transportadores, :documento,      :string
    add_column :transportadores, :cnh_numero,     :string
    add_column :transportadores, :placa_veiculo,  :string

    add_index :transportadores, :documento, unique: true
  end
end

