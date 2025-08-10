class CreateHistoricoProposta < ActiveRecord::Migration[7.1]
  def change
    create_table :historico_proposta do |t|
      t.text :conteudo

      t.timestamps
    end
  end
end
