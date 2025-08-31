class RenameCotacaosToCotacoes < ActiveRecord::Migration[7.1]
  def change
    rename_table :cotacaos, :cotacoes if table_exists?(:cotacaos)
  end
end
