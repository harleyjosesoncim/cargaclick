class AddLatLongToFretes < ActiveRecord::Migration[7.1]
  def change
    add_column :fretes, :latitude, :float
    add_column :fretes, :longitude, :float
  end
end
