class CreateCotacoes < ActiveRecord::Migration[7.1]
  def change
    create_table :cotacoes do |t|
      t.references :cliente, null: false, foreign_key: true
      t.string :origem
      t.string :destino
      t.decimal :peso
      t.decimal :volume
      t.string :status

      t.timestamps
    end
  end
end
