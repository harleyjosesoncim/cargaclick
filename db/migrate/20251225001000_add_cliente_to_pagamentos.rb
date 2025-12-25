class AddClienteToPagamentos < ActiveRecord::Migration[7.1]
  def change
    return if column_exists?(:pagamentos, :cliente_id)

    add_reference :pagamentos, :cliente, foreign_key: true, index: true
  end
end
