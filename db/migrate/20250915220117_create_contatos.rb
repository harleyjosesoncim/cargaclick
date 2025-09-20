# db/migrate/20250915220117_create_contatos.rb
class CreateContatos < ActiveRecord::Migration[7.1]
  def change
    create_table :contatos do |t|
      t.string :nome
      t.string :email
      t.text :mensagem

      t.timestamps
    end
  end
end
