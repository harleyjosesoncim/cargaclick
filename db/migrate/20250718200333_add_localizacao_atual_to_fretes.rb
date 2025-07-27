class AddLocalizacaoAtualToFretes < ActiveRecord::Migration[7.1]
  def change
    add_column :fretes, :latitude_atual_transportador, :float
    add_column :fretes, :longitude_atual_transportador, :float
  end
end
