# db/migrate/20251018191500_convert_transportadores_status_to_string.rb
class ConvertTransportadoresStatusToString < ActiveRecord::Migration[7.1]
  def up
    # cria coluna temporária como string
    add_column :transportadores, :status_text, :string, default: "pendente", null: false

    if column_exists?(:transportadores, :status, :integer)
      # mapeamento padrão; ajuste aqui se seus códigos forem outros
      execute <<~SQL.squish
        UPDATE transportadores
        SET status_text = CASE status
          WHEN 1 THEN 'ativo'
          WHEN 2 THEN 'bloqueado'
          WHEN 0 THEN 'pendente'
          ELSE 'pendente'
        END
      SQL
      remove_column :transportadores, :status
    elsif column_exists?(:transportadores, :status, :string)
      # já é string? só copia e segue
      execute "UPDATE transportadores SET status_text = COALESCE(status, 'pendente')"
      remove_column :transportadores, :status
    end

    rename_column :transportadores, :status_text, :status
    add_index :transportadores, :status
  end

  def down
    # rollback para integer (0 pendente, 1 ativo, 2 bloqueado)
    add_column :transportadores, :status_int, :integer, default: 0, null: false

    if column_exists?(:transportadores, :status, :string)
      execute <<~SQL.squish
        UPDATE transportadores
        SET status_int = CASE status
          WHEN 'ativo'     THEN 1
          WHEN 'bloqueado' THEN 2
          WHEN 'pendente'  THEN 0
          ELSE 0
        END
      SQL
      remove_column :transportadores, :status
    end

    rename_column :transportadores, :status_int, :status
    add_index :transportadores, :status
  end
end
