class CreateTransportadores < ActiveRecord::Migration[7.1]
  def change
    create_table :transportadores do |t|
      t.string :nome
      t.string :telefone
      t.string :cnpj
      t.decimal :volume
      t.decimal :peso

      t.timestamps
    end
  end
end
