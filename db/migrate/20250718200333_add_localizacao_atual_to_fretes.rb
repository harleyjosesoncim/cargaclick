class AddLocalizacaoAtualToFretes < ActiveRecord::Migration[7.1]
  def change
    add_column :fretes, :localizacao_atual, :string unless column_exists?(:fretes, :localizacao_atual)
  end
end
