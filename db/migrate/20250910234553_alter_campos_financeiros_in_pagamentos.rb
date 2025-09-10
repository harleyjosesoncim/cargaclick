class AlterCamposFinanceirosInPagamentos < ActiveRecord::Migration[7.1]
  def change
    change_column :pagamentos, :valor_total, :decimal, precision: 10, scale: 2
    change_column :pagamentos, :valor_liquido, :decimal, precision: 10, scale: 2
    change_column :pagamentos, :comissao_cargaclick, :decimal, precision: 10, scale: 2
  end
end
