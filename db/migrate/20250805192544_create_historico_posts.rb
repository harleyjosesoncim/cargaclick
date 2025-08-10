class CreateHistoricoPosts < ActiveRecord::Migration[7.1]
  def change
    create_table :historico_posts do |t|
      t.text :conteudo

      t.timestamps
    end
  end
end
