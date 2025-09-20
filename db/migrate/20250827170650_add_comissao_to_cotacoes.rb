class AddComissaoToCotacoes < ActiveRecord::Migration[7.1]
  def change
    add_column :cotacoes, :comissao, :decimal unless column_exists?(:cotacoes, :comissao)
  end
end
