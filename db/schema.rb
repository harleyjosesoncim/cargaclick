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

ActiveRecord::Schema[7.1].define(version: 2025_08_12_174324) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "clientes", force: :cascade do |t|
    t.string "nome"
    t.string "email"
    t.string "telefone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "endereco"
    t.string "cep"
    t.float "largura"
    t.float "altura"
    t.float "profundidade"
    t.float "peso_aproximado"
    t.string "observacoes", limit: 50
    t.integer "alba_numero"
    t.string "whatsapp"
    t.string "cpf"
    t.string "cnpj"
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.index ["email"], name: "index_clientes_on_email", unique: true
    t.index ["reset_password_token"], name: "index_clientes_on_reset_password_token", unique: true
  end

  create_table "configuracaos", force: :cascade do |t|
    t.float "comissao_padrao", default: 6.0
    t.float "comissao_assinante", default: 3.0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.string "origem"
    t.string "destino"
    t.text "descricao"
    t.integer "largura"
    t.integer "altura"
    t.integer "profundidade"
    t.integer "status", default: 0
    t.boolean "contatos_liberados"
    t.boolean "entregue", default: false
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

  create_table "modals", force: :cascade do |t|
    t.string "nome"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
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
    t.string "cpf"
    t.string "telefone"
    t.string "endereco"
    t.string "cep"
    t.string "tipo_veiculo"
    t.string "carga_maxima"
    t.decimal "valor_km"
    t.decimal "largura"
    t.decimal "altura"
    t.decimal "profundidade"
    t.decimal "peso_aproximado"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "fidelidade_pontos"
    t.string "cidade"
    t.string "email"
    t.index ["email"], name: "index_transportadores_on_email"
  end

end
