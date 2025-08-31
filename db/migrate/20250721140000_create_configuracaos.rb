class CreateConfiguracaos < ActiveRecord::Migration[7.1]
  def change
    create_table :configuracaos do |t|
      t.string :chave
      t.string :valor
      t.timestamps
    end unless table_exists?(:configuracaos)
  end
end
