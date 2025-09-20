class RenameCargaIdToFreteIdInCotacoes < ActiveRecord::Migration[7.1]
  def change
    if column_exists?(:cotacoes, :carga_id)
      rename_column :cotacoes, :carga_id, :frete_id
    end
  end
end
