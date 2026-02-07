class CreateTransportadores < ActiveRecord::Migration[6.1]
  def change
    create_table :transportadores do |t|
      t.string  :nome, null: false
      t.string  :telefone, null: false
      t.string  :email
      t.string  :cidade, null: false
      t.string  :tipo_veiculo, null: false
      t.integer :capacidade
      t.string  :origem, default: "site"
      t.string  :status, default: "pendente"
      t.timestamps
    end
  end
end
