class UpdateTransportadores < ActiveRecord::Migration[7.1]
  def change
    # 🔹 CPF: garante limite de 11 dígitos
    change_column :transportadores, :cpf, :string, limit: 11

    # 🔹 Garante que email tenha índice único (se for obrigatório no sistema)
    remove_index :transportadores, :email if index_exists?(:transportadores, :email)
    add_index :transportadores, :email, unique: true, where: "email IS NOT NULL"

    # 🔹 Carga máxima: de string para decimal (kg)
    # Obs: usando decimal com precisão de até 10 dígitos e 2 casas decimais
    change_column :transportadores, :carga_maxima, :decimal, precision: 10, scale: 2, using: "carga_maxima::numeric"
  end
end
