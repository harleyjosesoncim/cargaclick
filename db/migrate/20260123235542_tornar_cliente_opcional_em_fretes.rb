class TornarClienteOpcionalEmFretes < ActiveRecord::Migration[7.1]
  def change
    change_column_null :fretes, :cliente_id, true
  end
end
