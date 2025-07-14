class RenameCotacaosToCotacoes < ActiveRecord::Migration[7.0]
  def change
    rename_table :cotacaos, :cotacoes
  end
end
