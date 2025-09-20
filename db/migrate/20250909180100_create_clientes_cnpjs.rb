class CreateClientesCnpjs < ActiveRecord::Migration[6.1]
  def change
    create_table :clientes_cnpjs do |t|
      t.string  :nome_fantasia, null: false
      t.string  :razao_social
      t.string  :cnpj, null: false
      t.string  :email, null: false
      t.string  :telefone
      t.string  :endereco
      t.string  :cep
      t.string  :cidade
      t.string  :estado
      t.boolean :ativo, default: true

      # Vantagens comerciais
      t.decimal :desconto_cliente, precision: 5, scale: 2, default: 0.0
      t.decimal :bonus_entregador, precision: 5, scale: 2, default: 0.0
      t.decimal :taxa_cargaclick, precision: 5, scale: 2, default: 8.0

      t.timestamps
    end

    add_index :clientes_cnpjs, :cnpj, unique: true
  end
end
