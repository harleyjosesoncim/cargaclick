class SetDefaultFidelidadeInTransportadores < ActiveRecord::Migration[7.1]
  def change
    change_column_default :transportadores, :fidelidade_pontos, 0 if column_exists?(:transportadores, :fidelidade_pontos)
  end
end
