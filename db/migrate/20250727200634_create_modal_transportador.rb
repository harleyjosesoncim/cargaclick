class CreateModalTransportador < ActiveRecord::Migration[7.1]
  def change
    create_table :modal_transportadores do |t|
      t.references :modal, foreign_key: true
      t.references :transportador, foreign_key: true
      t.timestamps
    end unless table_exists?(:modal_transportadores)
  end
end
