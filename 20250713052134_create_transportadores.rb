class CreateTransportadores < ActiveRecord::Migration[7.1]
  def change
    create_table :transportadores do |t|
      t.string :nome
      t.string :cpf
      t.string :telefone
      t.string :endereco
      t.string :cep
      t.string :tipo_veiculo
      t.string :carga_maxima
      t.decimal :valor_km
      t.decimal :largura
      t.decimal :altura
      t.decimal :profundidade
      t.decimal :peso_aproximado
      t.timestamps
    end
  end
end
