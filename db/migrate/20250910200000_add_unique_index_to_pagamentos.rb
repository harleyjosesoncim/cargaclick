class AddUniqueIndexToPagamentos < ActiveRecord::Migration[6.1]
  def change
    add_index :pagamentos, [:frete_id, :transportador_id], unique: true, name: "idx_pagamentos_frete_transportador"
  end
end
# --- IGNORE ---