class UpdateClientes < ActiveRecord::Migration[7.1]
  def change
    change_column :clientes, :observacoes, :string, limit: 200 if column_exists?(:clientes, :observacoes)
    change_column :clientes, :cpf, :string, limit: 11 if column_exists?(:clientes, :cpf)
    change_column :clientes, :cnpj, :string, limit: 14 if column_exists?(:clientes, :cnpj)
    add_index :clientes, :cpf, unique: true, where: "cpf IS NOT NULL" unless index_exists?(:clientes, :cpf)
    add_index :clientes, :cnpj, unique: true, where: "cnpj IS NOT NULL" unless index_exists?(:clientes, :cnpj)
  end
end
