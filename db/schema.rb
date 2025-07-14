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

ActiveRecord::Schema[7.1].define(version: 2025_07_14_141714) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

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
    t.string "observacoes", limit: 50
    t.integer "alba_numero"
    t.string "whatsapp"
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
    t.string "status"
    t.boolean "aceite_responsabilidade"
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
  end

end
