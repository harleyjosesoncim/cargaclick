class CreateHistoricoEmails < ActiveRecord::Migration[7.1]
  def change
    create_table :historico_emails do |t|
      t.text :conteudo

      t.timestamps
    end
  end
end
