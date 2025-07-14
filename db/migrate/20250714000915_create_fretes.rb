class CreateFretes < ActiveRecord::Migration[7.1]
  def change
    create_table :fretes do |t|
      t.integer :cliente_id
      t.integer :transportador_id
      t.float :volume
      t.string :ponto_referencia
      t.string :horario_entrega
      t.string :previsao_chegada
      t.float :previsao_km
      t.float :valor_total
      t.string :status
      t.boolean :aceite_responsabilidade

      t.timestamps
    end
  end
end
