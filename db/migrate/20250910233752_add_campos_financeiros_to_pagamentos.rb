# db/migrate/20250910233752_add_campos_financeiros_to_pagamentos.rb
class AddCamposFinanceirosToPagamentos < ActiveRecord::Migration[7.1]
  def change
    add_column :pagamentos, :valor_total, :decimal, precision: 10, scale: 2
    add_column :pagamentos, :valor_liquido, :decimal, precision: 10, scale: 2
    add_column :pagamentos, :comissao_cargaclick, :decimal, precision: 10, scale: 2
  end
end

