# db/migrate/20250903170635_create_chat_and_support_tables.rb
class CreateChatAndSupportTables < ActiveRecord::Migration[7.1]
  def change
    # === AJUSTE COTAÇÕES ===================================
    unless column_exists?(:cotacoes, :transportador_id)
      add_column :cotacoes, :transportador_id, :bigint, null: false
    end

    add_foreign_key :cotacoes, :transportadores, column: :transportador_id
    add_index :cotacoes, [:frete_id, :transportador_id],
              unique: true,
              name: "idx_cotacoes_frete_transportador"

    # === MENSAGENS (CHAT) ===========================
    create_table :messages, if_not_exists: true do |t|
      t.references :frete, null: false, foreign_key: { to_table: :fretes }
      t.string :sender_type, null: false
      t.bigint :sender_id, null: false
      t.text :content, null: false
      t.integer :status, default: 0, null: false
      t.timestamps
    end
    add_index :messages, [:frete_id, :created_at]
    add_index :messages, [:sender_type, :sender_id], name: "idx_messages_sender"

    # === HISTÓRICO =================================
    create_table :historico_posts, if_not_exists: true do |t|
      t.references :frete, null: false, foreign_key: { to_table: :fretes }
      t.text :conteudo, null: false
      t.timestamps
    end

    create_table :historico_emails, if_not_exists: true do |t|
      t.references :frete, null: false, foreign_key: { to_table: :fretes }
      t.string :assunto, null: false
      t.text :conteudo, null: false
      t.timestamps
    end

    create_table :historico_propostas, if_not_exists: true do |t|
      t.references :frete, null: false, foreign_key: { to_table: :fretes }
      t.decimal :valor, precision: 10, scale: 2
      t.text :observacoes
      t.timestamps
    end

    # === PAGAMENTOS ================================
    create_table :pagamentos, if_not_exists: true do |t|
      t.references :frete, null: false, foreign_key: { to_table: :fretes }
      t.bigint :transportador_id, null: false
      t.decimal :valor, precision: 10, scale: 2
      t.string :status, default: "pendente", null: false
      t.timestamps
    end
    add_foreign_key :pagamentos, :tra
