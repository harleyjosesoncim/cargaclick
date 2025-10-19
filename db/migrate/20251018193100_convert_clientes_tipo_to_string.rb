# db/migrate/20251018193100_convert_clientes_tipo_to_string.rb
class ConvertClientesTipoToString < ActiveRecord::Migration[7.1]
  def up
    # cria coluna temporária como string
    add_column :clientes, :tipo_text, :string, default: "pf", null: false

    if column_exists?(:clientes, :tipo, :integer)
      execute <<~SQL.squish
        UPDATE clientes
        SET tipo_text = CASE tipo
          WHEN 1 THEN 'pj'
          WHEN 2 THEN 'avulso'
          WHEN 0 THEN 'pf'
          ELSE 'pf'
        END
      SQL
      remove_column :clientes, :tipo
    elsif column_exists?(:clientes, :tipo, :string)
      # já é string? apenas copia valores e remove a antiga
      execute "UPDATE clientes SET tipo_text = COALESCE(tipo, 'pf')"
      remove_column :clientes, :tipo
    end

    rename_column :clientes, :tipo_text, :tipo
    add_index :clientes, :tipo
  end

  def down
    # rollback para integer: pf=0, pj=1, avulso=2
    add_column :clientes, :tipo_int, :integer, default: 0, null: false

    if column_exists?(:clientes, :tipo, :string)
      execute <<~SQL.squish
        UPDATE clientes
        SET tipo_int = CASE tipo
          WHEN 'pj'      THEN 1
          WHEN 'avulso'  THEN 2
          WHEN 'pf'      THEN 0
          ELSE 0
        END
      SQL
      remove_column :clientes, :tipo
    end

    rename_column :clientes, :tipo_int, :tipo
    add_index :clientes, :tipo
  end
end
