class CreateLeads < ActiveRecord::Migration[7.1]
  def change
    create_table :leads do |t|
      t.string :tipo       # cliente ou transportador
      t.string :nome
      t.string :contato
      t.string :origem
      t.string :destino
      t.text :detalhes

      t.timestamps
    end
  end
end
