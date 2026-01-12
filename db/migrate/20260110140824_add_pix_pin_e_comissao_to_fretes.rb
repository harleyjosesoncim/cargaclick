class AddPixPinEComissaoToFretes < ActiveRecord::Migration[7.1]
  def change
    # PIX
    add_column :fretes, :pix_txid, :string
    add_column :fretes, :pix_copia_cola, :text
    add_column :fretes, :pix_qr_code, :text
    add_column :fretes, :status_pagamento, :string, default: "pendente", null: false

    # PIN DE ENTREGA
    add_column :fretes, :pin_entrega, :string
    add_column :fretes, :tentativas_pin, :integer, default: 0, null: false
    add_column :fretes, :entregue_em, :datetime

    # MONETIZAÇÃO
    add_column :fretes, :comissao_percentual, :decimal, precision: 5, scale: 2
    add_column :fretes, :valor_comissao, :decimal, precision: 10, scale: 2
    add_column :fretes, :valor_transportador, :decimal, precision: 10, scale: 2

    add_index :fretes, :pix_txid, unique: true
    add_index :fretes, :status_pagamento
  end
end

