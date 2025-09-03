# db/migrate/20250903170635_create_chat_and_support_tables.rb
class CreateChatAndSupportTables < ActiveRecord::Migration[7.1]
  def change
    # === COTAÇÕES ===================================
    # Uma cotação (orçamento) pertence a um frete e a um transportador
    create_table :cotacoes, if_not_exists: true do |t|
      t.references :frete, null: false, foreign_key: true               # ligação com o frete solicitado pelo cliente
      t.references :transportador, null: false, foreign_key: true       # ligação com quem fez a oferta
      t.decimal :valor, precision: 10, scale: 2                         # valor proposto
      t.integer :status, default: 0, null: false                        # 0=pendente, 1=aceita, 2=rejeitada
      t.decimal :comissao, precision: 10, scale: 2                      # % ou valor fixo de comissão
      t.timestamps
    end
    add_index :cotacoes, [:frete_id, :transportador_id], unique: true, name: "idx_cotacoes_frete_transportador" unless index_exists?(:cotacoes, [:frete_id, :transportador_id], name: "idx_cotacoes_frete_transportador")

    # === MENSAGENS (CHAT) ===========================
    # Mensagens entre cliente e transportador, sempre atreladas a um frete
    create_table :messages, if_not_exists: true do |t|
      t.references :frete, null: false, foreign_key: true
      t.string :sender_type, null: false                                # "Cliente" ou "Transportador"
      t.bigint :sender_id, null: false                                  # id do remetente (cliente_id ou transportador_id)
      t.text :content, null: false                                      # conteúdo da mensagem
      t.integer :status, default: 0, null: false                        # 0=normal, 1=lido, 2=importante
      t.timestamps
    end
    add_index :messages, [:frete_id, :created_at] unless index_exists?(:messages, [:frete_id, :created_at])
    add_index :messages, [:sender_type, :sender_id], name: "idx_messages_sender" unless index_exists?(:messages, [:sender_type, :sender_id], name: "idx_messages_sender")

    # === HISTÓRICO (log do frete) ===================
    create_table :historico_posts, if_not_exists: true do |t|
      t.references :frete, null: false, foreign_key: true
      t.text :conteudo, null: false
      t.timestamps
    end

    create_table :historico_emails, if_not_exists: true do |t|
      t.references :frete, null: false, foreign_key: true
      t.string :assunto, null: false
      t.text :conteudo, null: false
      t.timestamps
    end

    create_table :historico_propostas, if_not_exists: true do |t|
      t.references :frete, null: false, foreign_key: true
      t.decimal :valor, precision: 10, scale: 2
      t.text :observacoes
      t.timestamps
    end

    # === PAGAMENTOS ================================
    # Pagamento liga um transportador a um frete realizado
    create_table :pagamentos, if_not_exists: true do |t|
      t.references :transportador, null: false, foreign_key: true
      t.references :frete, null: false, foreign_key: true
      t.decimal :valor, precision: 10, scale: 2
      t.string :status, default: "pendente", null: false                # pendente, confirmado, cancelado
      t.timestamps
    end
    add_index :pagamentos, [:frete_id, :transportador_id], name: "idx_pagamentos_frete_transportador" unless index_exists?(:pagamentos, [:frete_id, :transportador_id], name: "idx_pagamentos_frete_transportador")

    # === ADMIN USERS ===============================
    # Usuários administrativos para gerenciar o sistema (Devise)
    create_table :admin_users, if_not_exists: true do |t|
      t.string :email,              null: false, default: ""
      t.string :encrypted_password, null: false, default: ""
      t.string :reset_password_token
      t.datetime :reset_password_sent_at
      t.datetime :remember_created_at
      t.timestamps
    end
    add_index :admin_users, :email, unique: true unless index_exists?(:admin_users, :email)
    add_index :admin_users, :reset_password_token, unique: true unless index_exists?(:admin_users, :reset_password_token)
  end
end
