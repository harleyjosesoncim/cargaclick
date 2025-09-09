# frozen_string_literal: true
class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      t.text :content, null: false

      # Associação obrigatória ao Chat
      t.references :chat, null: false, foreign_key: true

      # Sender polimórfico (Cliente ou Transportador)
      t.references :sender, polymorphic: true, null: false

      # Status da mensagem
      t.integer :status, default: 0, null: false # enum: normal=0, lido=1, importante=2

      t.timestamps
    end

    # Índice para melhorar buscas por chat e ordem
    add_index :messages, [:chat_id, :created_at], name: "idx_messages_chat_created_at"
  end
end
