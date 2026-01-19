class AddPesoAndVolumeToFretes < ActiveRecord::Migration[7.1]
  def change
    add_column :fretes, :peso, :decimal, precision: 10, scale: 2
    add_column :fretes, :volume, :decimal, precision: 10, scale: 2
  end
end
