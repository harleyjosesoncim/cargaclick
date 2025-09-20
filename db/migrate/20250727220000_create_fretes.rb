class CreateFretes < ActiveRecord::Migration[7.1]
  def change
    unless table_exists?(:fretes)
      create_table :fretes do |t|
        # relações
        t.references :cliente, null: false, foreign_key: true
        t.references :transportador, null: true, foreign_key: true

        # informações básicas
        t.string  :origem,  null: false
        t.string  :destino, null: false

        # medidas e peso
        t.decimal :largura, precision: 10, scale: 2
        t.decimal :altura, precision: 10, scale: 2
        t.decimal :profundidade, precision: 10, scale: 2
        t.decimal :peso_aproximado, precision: 10, scale: 2

        # valores
        t.decimal :valor_estimado, precision: 10, scale: 2
        t.decimal :valor_final, precision: 10, scale: 2

        # status do frete
        t.string :status, default: "pendente"

        t.timestamps
      end
    end
  end
end


