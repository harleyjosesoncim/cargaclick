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

ActiveRecord::Schema[7.1].define(version: 2025_09_02_001949) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "admin_users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "nome"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_admin_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_admin_users_on_reset_password_token", unique: true
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
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.string "confirmation_token"
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "campo"
    t.index ["cnpj"], name: "index_clientes_on_cnpj", unique: true, where: "(cnpj IS NOT NULL)"
    t.index ["confirmation_token"], name: "index_clientes_on_confirmation_token", unique: true
    t.index ["cpf"], name: "index_clientes_on_cpf", unique: true, where: "(cpf IS NOT NULL)"
    t.index ["email"], name: "index_clientes_on_email", unique: true
    t.index ["reset_password_token"], name: "index_clientes_on_reset_password_token", unique: true
  end

  create_table "configs", force: :cascade do |t|
    t.decimal "comissao_padrao"
    t.decimal "comissao_assinante"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "configuracaos", force: :cascade do |t|
    t.float "comissao_padrao", default: 6.0
    t.float "comissao_assinante", default: 3.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "cotacoes", force: :cascade do |t|
    t.integer "cliente_id"
    t.string "origem"
    t.string "destino"
    t.float "peso"
    t.float "volume"
    t.string "status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "comissao"
  end

  create_table "fretes", force: :cascade do |t|
    t.integer "cliente_id"
    t.integer "transportador_id"
    t.float "volume"
    t.string "ponto_referencia"
    t.string "horario_entrega"
    t.string "previsao_chegada"
    t.float "previsao_km"
    t.float "valor_total"
    t.boolean "aceite_responsabilidade"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "cep_origem"
    t.string "cep_destino"
    t.decimal "peso", precision: 8, scale: 2
    t.decimal "distancia", precision: 8, scale: 2
    t.decimal "valor_estimado", precision: 10, scale: 2
    t.float "latitude"
    t.float "longitude"
    t.string "cep_atual"
    t.float "latitude_atual_transportador"
    t.float "longitude_atual_transportador"
    t.boolean "entregue"
    t.string "origem"
    t.string "destino"
    t.text "descricao"
    t.integer "largura"
    t.integer "altura"
    t.integer "profundidade"
    t.integer "status", default: 0
    t.boolean "contatos_liberados"
    t.string "cliente_nome"
  end

  create_table "historico_emails", force: :cascade do |t|
    t.text "conteudo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "historico_posts", force: :cascade do |t|
    t.text "conteudo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "historico_proposta", force: :cascade do |t|
    t.text "conteudo"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "leads", force: :cascade do |t|
    t.string "tipo"
    t.string "nome"
    t.string "contato"
    t.string "origem"
    t.string "destino"
    t.text "detalhes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "canal", default: "mock"
  end

  create_table "messages", force: :cascade do |t|
    t.bigint "frete_id", null: false
    t.string "sender_type", null: false
    t.bigint "sender_id", null: false
    t.text "content", null: false
    t.integer "status", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["frete_id", "created_at"], name: "index_messages_on_frete_id_and_created_at"
    t.index ["frete_id"], name: "index_messages_on_frete_id"
    t.index ["sender_type", "sender_id"], name: "index_messages_on_sender"
    t.index ["status"], name: "index_messages_on_status"
  end

  create_table "modal_transportadores", force: :cascade do |t|
    t.bigint "transportador_id", null: false
    t.bigint "modal_id", null: false
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

  create_table "proposta", force: :cascade do |t|
    t.bigint "frete_id", null: false
    t.bigint "transportador_id", null: false
    t.decimal "valor_proposto"
    t.text "observacao"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["frete_id"], name: "index_proposta_on_frete_id"
    t.index ["transportador_id"], name: "index_proposta_on_transportador_id"
  end

  create_table "propostas", force: :cascade do |t|
    t.decimal "valor_proposto", precision: 10, scale: 2
    t.text "observacao"
    t.string "status", default: "pendente"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.datetime "confirmed_at"
    t.datetime "confirmation_sent_at"
    t.string "unconfirmed_email"
    t.string "pix_key"
    t.string "mercado_pago_link"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["confirmation_token"], name: "index_transportadores_on_confirmation_token", unique: true
    t.index ["email"], name: "index_transportadores_on_email", unique: true, where: "(email IS NOT NULL)"
    t.index ["reset_password_token"], name: "index_transportadores_on_reset_password_token", unique: true
  end

  add_foreign_key "messages", "fretes"
  add_foreign_key "modal_transportadores", "modals"
  add_foreign_key "modal_transportadores", "transportadores"
  add_foreign_key "proposta", "fretes"
  add_foreign_key "proposta", "transportadores"
end
