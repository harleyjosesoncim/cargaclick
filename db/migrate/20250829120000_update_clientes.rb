class UpdateClientes < ActiveRecord::Migration[7.1]
  def change
    # 🔹 Ajusta limite do campo observacoes (de 50 → 200 chars)
    change_column :clientes, :observacoes, :string, limit: 200

    # 🔹 Ajusta CPF (se usar sempre números, limite 11)
    change_column :clientes, :cpf, :string, limit: 11

    # 🔹 Ajusta CNPJ (se usar, limite 14)
    change_column :clientes, :cnpj, :string, limit: 14

    # 🔹 Garante índice único para CPF e CNPJ (se forem usados como identificadores)
    add_index :clientes, :cpf, unique: true, where: "cpf IS NOT NULL"
    add_index :clientes, :cnpj, unique: true, where: "cnpj IS NOT NULL"
  end
end
