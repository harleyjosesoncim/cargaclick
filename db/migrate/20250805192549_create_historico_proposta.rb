class CreateHistoricoProposta < ActiveRecord::Migration[7.1]
  def change
    create_table :historico_propostas do |t|
      t.references :cliente, foreign_key: true
      t.references :proposta, foreign_key: true
      t.text :observacao
      t.timestamps
    end unless table_exists?(:historico_propostas)
  end
end
