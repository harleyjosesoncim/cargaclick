# frozen_string_literal: true
class CreateChats < ActiveRecord::Migration[7.1]
  def change
    create_table :chats do |t|
      t.references :frete,        null: false, foreign_key: true
      t.references :cliente,      null: false, foreign_key: true
      t.references :transportador, null: false, foreign_key: true

      t.boolean :ativo, default: true, null: false

      t.timestamps
    end

    # Garante que não exista mais de um chat para o mesmo frete + cliente + transportador
    add_index :chats, [:frete_id, :cliente_id, :transportador_id],
              unique: true,
              name: "idx_chats_unico_frete_cliente_transportador"
  end
end
