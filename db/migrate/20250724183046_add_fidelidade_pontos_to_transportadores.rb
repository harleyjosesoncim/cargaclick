class AddFidelidadePontosToTransportadores < ActiveRecord::Migration[7.1]
  def change
    add_column :transportadores, :fidelidade_pontos, :integer, default: 0 unless column_exists?(:transportadores, :fidelidade_pontos)
  end
end
