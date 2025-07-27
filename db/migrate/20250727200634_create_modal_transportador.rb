class CreateModalTransportador < ActiveRecord::Migration[7.1]
  def change
    create_table :modal_transportadores do |t|
      t.references :transportador, null: false, foreign_key: true
      t.references :modal, null: false, foreign_key: true

      t.timestamps
    end
  end
end
