class CreateHistoricoPosts < ActiveRecord::Migration[7.1]
  def change
    create_table :historico_posts do |t|
      t.references :cliente, foreign_key: true
      t.text :conteudo
      t.timestamps
    end unless table_exists?(:historico_posts)
  end
end
