
class CreateContratosDigitais < ActiveRecord::Migration[7.1]
  def change
    create_table :contratos_digitais do |t|
      t.references :frete, null: false, foreign_key: true
      t.references :cliente, null: false, foreign_key: true
      t.references :transportador, null: false, foreign_key: true

      t.text :conteudo
      t.string :hash_documento, null: false
      t.string :status, default: "pendente"

      t.datetime :aceito_em
      t.string :aceito_ip
      t.string :aceito_user_agent

      t.timestamps
    end

    add_index :contratos_digitais, :hash_documento, unique: true
  end
end
