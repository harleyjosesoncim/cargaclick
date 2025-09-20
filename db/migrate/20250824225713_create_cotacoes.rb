class CreateCotacoes < ActiveRecord::Migration[7.1]
  def change
    create_table :cotacoes do |t|
      t.references :cliente, foreign_key: true
      t.references :frete, foreign_key: true
      t.decimal :valor, precision: 10, scale: 2
      t.timestamps
    end unless table_exists?(:cotacoes)
  end
end
