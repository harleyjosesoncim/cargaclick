# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2025_10_18_193100) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
  end

  create_table "avaliacoes", force: :cascade do |t|
    t.bigint "frete_id", null: false
    t.bigint "cliente_id"
    t.bigint "transportador_id"
    t.integer "nota", null: false
    t.text "comentario"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cliente_id"], name: "index_avaliacoes_on_cliente_id"
    t.index ["frete_id"], name: "index_avaliacoes_on_frete_id"
    t.index ["transportador_id"], name: "index_avaliacoes_on_transportador_id"
  end

  create_table "chats", force: :cascade do |t|
    t.bigint "frete_id", null: false
    t.bigint "cliente_id", null: false
    t.bigint "transportador_id", null: false
    t.boolean "ativo", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cliente_id"], name: "index_chats_on_cliente_id"
    t.index ["frete_id", "cliente_id", "transportador_id"], name: "idx_chats_unico_frete_cliente_transportador", unique: true
    t.index ["frete_id"], name: "index_chats_on_frete_id"
    t.index ["transportador_id"], name: "index_chats_on_transportador_id"
  end

  create_table "clientes", force: :cascade do |t|
    t.string "nome"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "telefone"
    t.string "endereco"
    t.string "cep"
    t.float "largura"
    t.float "altura"
    t.float "profundidade"
    t.float "peso_aproximado"
    t.string "observacoes", limit: 200
    t.integer "alba_numero"
    t.string "whatsapp"
    t.string "cpf", limit: 11
    t.string "cnpj", limit: 14
    t.string "encrypted_password", default: "", null: false
    t.string "confirmation_token"
    t.string "campo_extra"
    t.string "tipo", default: "pf", null: false
    t.index ["cnpj"], name: "index_clientes_on_cnpj", unique: true, where: "(cnpj IS NOT NULL)"
    t.index ["cpf"], name: "index_clientes_on_cpf", unique: true, where: "(cpf IS NOT NULL)"
    t.index ["tipo"], name: "index_clientes_on_tipo"
  end

  create_table "clientes_cnpjs", force: :cascade do |t|
    t.string "nome_fantasia", null: false
    t.string "razao_social"
    t.string "cnpj", null: false
    t.string "email", null: false
    t.string "telefone"
    t.string "endereco"
    t.string "cep"
    t.string "cidade"
    t.string "estado"
    t.boolean "ativo", default: true
    t.decimal "desconto_cliente", precision: 5, scale: 2, default: "0.0"
    t.decimal "bonus_entregador", precision: 5, scale: 2, default: "0.0"
    t.decimal "taxa_cargaclick", precision: 5, scale: 2, default: "8.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cnpj"], name: "index_clientes_cnpjs_on_cnpj", unique: true
  end

  create_table "configs", force: :cascade do |t|
    t.decimal "comissao_padrao"
    t.decimal "comissao_assinante"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "configuracaos", force: :cascade do |t|
    t.string "chave"
    t.string "valor"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "contatos", force: :cascade do |t|
    t.string "nome"
    t.string "email"
    t.text "mensagem"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cotacoes", force: :cascade do |t|
    t.bigint "cliente_id"
    t.bigint "frete_id"
    t.decimal "valor", precision: 10, scale: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "comissao"
    t.string "status", default: "pendente", null: false
    t.index ["cliente_id"], name: "index_cotacoes_on_cliente_id"
    t.index ["frete_id"], name: "index_cotacoes_on_frete_id"
    t.index ["status"], name: "index_cotacoes_on_status"
  end

  create_table "fretes", force: :cascade do |t|
    t.bigint "cliente_id", null: false
    t.bigint "transportador_id"
    t.string "origem", null: false
    t.string "destino", null: false
    t.decimal "largura", precision: 10, scale: 2
    t.decimal "altura", precision: 10, scale: 2
    t.decimal "profundidade", precision: 10, scale: 2
    t.decimal "peso_aproximado", precision: 10, scale: 2
    t.decimal "valor_estimado", precision: 10, scale: 2
    t.decimal "valor_final", precision: 10, scale: 2
    t.string "status", default: "pendente"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cliente_id"], name: "index_fretes_on_cliente_id"
    t.index ["transportador_id"], name: "index_fretes_on_transportador_id"
  end

  create_table "historico_emails", force: :cascade do |t|
    t.bigint "cliente_id"
    t.text "conteudo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cliente_id"], name: "index_historico_emails_on_cliente_id"
  end

  create_table "historico_posts", force: :cascade do |t|
    t.bigint "cliente_id"
    t.text "conteudo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cliente_id"], name: "index_historico_posts_on_cliente_id"
  end

  create_table "historico_propostas", force: :cascade do |t|
    t.bigint "cliente_id"
    t.bigint "proposta_id"
    t.text "observacao"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cliente_id"], name: "index_historico_propostas_on_cliente_id"
    t.index ["proposta_id"], name: "index_historico_propostas_on_proposta_id"
  end

  create_table "leads", force: :cascade do |t|
    t.string "nome"
    t.string "email"
    t.string "telefone"
    t.string "canal"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "channel"
  end

  create_table "modal_transportadores", force: :cascade do |t|
    t.bigint "modal_id"
    t.bigint "transportador_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["modal_id"], name: "index_modal_transportadores_on_modal_id"
    t.index ["transportador_id"], name: "index_modal_transportadores_on_transportador_id"
  end

  create_table "modals", force: :cascade do |t|
    t.string "nome"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "pagamentos", force: :cascade do |t|
    t.bigint "transportador_id", null: false
    t.bigint "frete_id", null: false
    t.decimal "valor", precision: 10, scale: 2, null: false
    t.decimal "taxa", precision: 10, scale: 2, default: "0.0"
    t.decimal "comissao", precision: 10, scale: 2, default: "0.0"
    t.decimal "desconto", precision: 10, scale: 2, default: "0.0"
    t.decimal "valor_liquido", precision: 10, scale: 2, default: "0.0"
    t.string "status", default: "pendente"
    t.string "metodo_pagamento"
    t.string "txid"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["frete_id"], name: "index_pagamentos_on_frete_id"
    t.index ["transportador_id"], name: "index_pagamentos_on_transportador_id"
  end

  create_table "propostas", force: :cascade do |t|
    t.bigint "cliente_id", null: false
    t.bigint "transportador_id", null: false
    t.bigint "frete_id", null: false
    t.decimal "valor", precision: 10, scale: 2, default: "0.0", null: false
    t.text "descricao"
    t.boolean "bolsa", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["cliente_id"], name: "index_propostas_on_cliente_id"
    t.index ["frete_id"], name: "index_propostas_on_frete_id"
    t.index ["transportador_id"], name: "index_propostas_on_transportador_id"
    t.index ["valor"], name: "index_propostas_on_valor"
  end

  create_table "transportadores", force: :cascade do |t|
    t.string "nome"
    t.string "cpf", limit: 11
    t.string "telefone"
    t.string "endereco"
    t.string "cep"
    t.string "tipo_veiculo"
    t.decimal "carga_maxima", precision: 10, scale: 2
    t.decimal "valor_km"
    t.decimal "largura"
    t.decimal "altura"
    t.decimal "profundidade"
    t.decimal "peso_aproximado"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "fidelidade_pontos", default: 0
    t.string "cidade"
    t.string "email"
    t.string "confirmation_token"
    t.string "pix_key"
    t.string "mercado_pago_link"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "chave_pix"
    t.string "status", default: "pendente", null: false
    t.index ["confirmation_token"], name: "index_transportadores_on_confirmation_token", unique: true
    t.index ["email"], name: "index_transportadores_on_email", unique: true, where: "(email IS NOT NULL)"
    t.index ["reset_password_token"], name: "index_transportadores_on_reset_password_token", unique: true
    t.index ["status"], name: "index_transportadores_on_status"
  end

  add_foreign_key "avaliacoes", "clientes"
  add_foreign_key "avaliacoes", "fretes"
  add_foreign_key "avaliacoes", "transportadores"
  add_foreign_key "chats", "clientes"
  add_foreign_key "chats", "fretes"
  add_foreign_key "chats", "transportadores"
  add_foreign_key "cotacoes", "clientes"
  add_foreign_key "cotacoes", "fretes"
  add_foreign_key "fretes", "clientes"
  add_foreign_key "fretes", "transportadores"
  add_foreign_key "historico_emails", "clientes"
  add_foreign_key "historico_posts", "clientes"
  add_foreign_key "historico_propostas", "clientes"
  add_foreign_key "historico_propostas", "propostas"
  add_foreign_key "modal_transportadores", "modals"
  add_foreign_key "modal_transportadores", "transportadores"
  add_foreign_key "pagamentos", "fretes"
  add_foreign_key "pagamentos", "transportadores"
  add_foreign_key "propostas", "clientes"
  add_foreign_key "propostas", "fretes"
  add_foreign_key "propostas", "transportadores"
end
