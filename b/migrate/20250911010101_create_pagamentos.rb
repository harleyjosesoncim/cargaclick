class CreatePagamentos < ActiveRecord::Migration[7.1]
  def change
    create_table :pagamentos do |t|
      t.references :frete, null: false, foreign_key: true
      t.references :cliente, null: false, foreign_key: true
      t.references :transportador, null: false, foreign_key: true

      t.decimal :valor_total, precision: 10, scale: 2, null: false
      t.string :status, default: "pendente"
      t.string :mp_payment_id
      t.string :mp_preference_id

      t.timestamps
    end
  end
end
