# frozen_string_literal: true
class SetDefaultFidelidadeInTransportadores < ActiveRecord::Migration[7.1]
  def change
    change_column_default :transportadores, :fidelidade_pontos, from: nil, to: 0
    # Opcional: zera os nulos existentes no banco, pra alinhar com o default
    Transportador.where(fidelidade_pontos: nil).update_all(fidelidade_pontos: 0)
  end
end
