# db/migrate/20250829121500_update_transportadores.rb
class UpdateTransportadores < ActiveRecord::Migration[7.1]
  def up
    # Ajusta CPF
    if column_exists?(:transportadores, :cpf)
      change_column :transportadores, :cpf, :string, limit: 11
    end

    # Ajusta índice de email (garantindo unicidade apenas se não existir)
    if index_exists?(:transportadores, :email)
      remove_index :transportadores, :email
    end
    add_index :transportadores, :email, unique: true, where: "email IS NOT NULL" unless index_exists?(:transportadores, :email)

    # Ajusta carga_maxima para decimal com precisão/escala
    if column_exists?(:transportadores, :carga_maxima)
      execute <<-SQL
        ALTER TABLE transportadores
        ALTER COLUMN carga_maxima TYPE decimal(10,2)
        USING carga_maxima::numeric(10,2);
      SQL
    end
  end

  def down
    # Reverte CPF
    if column_exists?(:transportadores, :cpf)
      change_column :transportadores, :cpf, :string
    end

    # Remove índice condicionalmente
    remove_index :transportadores, :email if index_exists?(:transportadores, :email)

    # Volta carga_maxima para integer (ou outro tipo original)
    if column_exists?(:transportadores, :carga_maxima)
      execute <<-SQL
        ALTER TABLE transportadores
        ALTER COLUMN carga_maxima TYPE integer
        USING round(carga_maxima);
      SQL
    end
  end
end
