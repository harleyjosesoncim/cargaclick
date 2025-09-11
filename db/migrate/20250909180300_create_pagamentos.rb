class CreatePagamentos < ActiveRecord::Migration[6.1]
  def change
    create_table :pagamentos do |t|
      t.references :transportador, null: false, foreign_key: true
      t.references :frete, null: false, foreign_key: true

      # valores
      t.decimal :valor, precision: 10, scale: 2, null: false
      t.decimal :taxa, precision: 10, scale: 2, default: 0   # taxa do sistema
      t.decimal :comissao, precision: 10, scale: 2, default: 0 # comissão do CargaClick
      t.decimal :desconto, precision: 10, scale: 2, default: 0 # descontos aplicados
      t.decimal :valor_liquido, precision: 10, scale: 2, default: 0 # transportador recebe

      # status e controle
      t.string  :status, default: "pendente" # pendente, confirmado, cancelado
      t.string  :metodo_pagamento # pix, cartão, boleto
      t.string  :txid # identificador Pix

      t.timestamps
    end
  end
end
