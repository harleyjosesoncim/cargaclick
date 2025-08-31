class CreateMessages < ActiveRecord::Migration[7.1]
  def change
    create_table :messages do |t|
      # 🔹 Associação obrigatória ao frete
      t.references :frete, null: false, foreign_key: true

      # 🔹 Polimórfico: pode ser Cliente ou Transportador
      t.references :sender, polymorphic: true, null: false

      # 🔹 Conteúdo da mensagem
      t.text :content, null: false

      # 🔹 Status (enum: 0=unread, 1=read)
      t.integer :status, null: false, default: 0

      t.timestamps
    end

    # Índices auxiliares
    add_index :messages, :status
    add_index :messages, [:frete_id, :created_at]
  end
end
