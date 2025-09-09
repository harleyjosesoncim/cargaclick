class CreatePagamentos < ActiveRecord::Migration[6.1]
  def change
    create_table :pagamentos do |t|
      t.references :transportador, null: false, foreign_key: true
      t.references :frete, null: false, foreign_key: true
      t.decimal :valor, precision: 10, scale: 2, null: false
      t.string  :status, default: "pendente" # pendente, confirmado, cancelado
      t.string  :txid # identificador Pix, se houver

      t.timestamps
    end
  end
end
