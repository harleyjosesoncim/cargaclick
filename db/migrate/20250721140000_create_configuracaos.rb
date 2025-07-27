class CreateConfiguracaos < ActiveRecord::Migration[6.1]
  def change
    create_table :configuracaos do |t|
      t.float :comissao_padrao, default: 6.0
      t.float :comissao_assinante, default: 3.0

      t.timestamps
    end
  end
end
