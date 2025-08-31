class AddLatLongToFretes < ActiveRecord::Migration[7.1]
  def change
    add_column :fretes, :latitude, :decimal, precision: 10, scale: 6 unless column_exists?(:fretes, :latitude)
    add_column :fretes, :longitude, :decimal, precision: 10, scale: 6 unless column_exists?(:fretes, :longitude)
  end
end
