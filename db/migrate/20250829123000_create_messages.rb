# frozen_string_literal: true
class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages, if_not_exists: true do |t|
      t.references :frete, null: false, foreign_key: true
      t.string :sender_type, null: false   # Cliente ou Transportador
      t.bigint :sender_id, null: false
      t.text :content, null: false
      t.integer :status, default: 0, null: false  # 0=unread, 1=read
      t.timestamps
    end

    add_index :messages, [:frete_id, :created_at] unless index_exists?(:messages, [:frete_id, :created_at])
    add_index :messages, [:sender_type, :sender_id] unless index_exists?(:messages, [:sender_type, :sender_id])
  end
end
