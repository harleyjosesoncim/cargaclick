class AddCamposBolsaProposta < ActiveRecord::Migration[7.1]
  def change
    # Campos para frete
    add_column :fretes, :cep_origem, :string
    add_column :fretes, :cep_destino, :string
    add_column :fretes, :peso, :decimal, precision: 8, scale: 2
    add_column :fretes, :distancia, :decimal, precision: 8, scale: 2
    add_column :fretes, :valor_estimado, :decimal, precision: 10, scale: 2
    # add_column :fretes, :status, :string, default: "aberto"
    # add_reference :fretes, :cliente, foreign_key: true

    # WhatsApp no cliente
    # add_column :clientes, :whatsapp, :string

    # Tabela propostas
    create_table :propostas do |t|
      # t.references :frete, null: false, foreign_key: true
      # t.references :transportador, null: false, foreign_key: true
      t.decimal :valor_proposto, precision: 10, scale: 2
      t.text :observacao
      t.string :status, default: "pendente"
      t.timestamps
    end
  end
end
