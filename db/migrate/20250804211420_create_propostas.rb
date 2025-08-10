class CreatePropostas < ActiveRecord::Migration[7.1]
  def up
    # Tabela já existe. Nada a fazer aqui.
  end

  def down
    drop_table :propostas
  end
end

