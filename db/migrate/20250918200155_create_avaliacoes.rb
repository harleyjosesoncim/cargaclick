class CreateAvaliacoes < ActiveRecord::Migration[7.1]
  def change
    create_table :avaliacoes do |t|
      t.references :frete, null: false, foreign_key: true
      t.references :cliente, foreign_key: true
      t.references :transportador, foreign_key: true

      t.integer :nota, null: false
      t.text :comentario, limit: 500

      t.timestamps
    end
  end
end
