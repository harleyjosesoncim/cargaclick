class AddFidelidadePontosToTransportadores < ActiveRecord::Migration[7.1]
  def change
    add_column :transportadores, :fidelidade_pontos, :integer
  end
end
