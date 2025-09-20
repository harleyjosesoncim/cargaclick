class RenameCargaIdToFreteIdInCotacoes < ActiveRecord::Migration[7.1]
  def change
    rename_column :cotacoes, :carga_id, :frete_id
  end
end
