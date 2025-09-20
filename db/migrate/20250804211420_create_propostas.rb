# db/migrate/20250804211420_create_propostas.rb
class CreatePropostas < ActiveRecord::Migration[6.1]
  def change
    create_table :propostas do |t|
      t.references :cliente, null: false, foreign_key: true
      t.references :transportador, null: false, foreign_key: true
      t.references :frete, null: false, foreign_key: true

      t.decimal :valor, precision: 10, scale: 2, null: false, default: 0.0
      t.text :descricao
      t.boolean :bolsa, default: false, null: false

      t.timestamps
    end

    # Índice para consultas rápidas por valor
    add_index :propostas, :valor
  end
end
# db/migrate/20250804211420_create_propostas.rb