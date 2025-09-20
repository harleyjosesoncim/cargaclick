class CreateConfigs < ActiveRecord::Migration[7.1]
  def change
    create_table :configs do |t|
      t.decimal :comissao_padrao
      t.decimal :comissao_assinante
      t.timestamps
    end unless table_exists?(:configs)
  end
end
