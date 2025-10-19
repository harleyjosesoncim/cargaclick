# db/migrate/20251018193000_add_status_to_cotacoes.rb
class AddStatusToCotacoes < ActiveRecord::Migration[7.1]
  def change
    unless column_exists?(:cotacoes, :status)
      add_column :cotacoes, :status, :string, null: false, default: "pendente"
      add_index  :cotacoes, :status
    end
  end
end
