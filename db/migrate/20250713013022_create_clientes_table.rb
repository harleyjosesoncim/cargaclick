# db/migrate/YYYYMMDDHHMMSS_create_clientes_table.rb (o nome do arquivo terá uma data/hora diferente)
class CreateClientesTable < ActiveRecord::Migration[7.0] # Mantendo 7.0 para consistência, mas 7.1 funciona
  def change
    # CRIA A TABELA 'clientes' (plural de Cliente)
    # E ADICIONA AS COLUNAS 'nome' e 'email'
    create_table :clientes do |t|
      t.string :nome  # Adiciona a coluna 'nome' como string
      t.string :email # Adiciona a coluna 'email' como string

      t.timestamps # Adiciona as colunas 'created_at' e 'updated_at' automaticamente
    end
  end
end