# lib/tasks/safe_migrate.rake
namespace :safe do
  desc "Sobe migrations pendentes; se a estrutura já existir, marca como aplicada"
  task migrate: :environment do
    require "active_record"
    pending = ActiveRecord::Base.connection.select_values("SELECT version FROM schema_migrations")
    dir = ActiveRecord::Migrator.migrations_paths.first
    migrations = ActiveRecord::MigrationContext.new([dir]).migrations

    to_run = migrations.reject { |m| pending.include?(m.version.to_s) }
                       .sort_by(&:version)

    puts "Encontradas #{to_run.size} migrations pendentes."

    to_run.each do |m|
      version = m.version.to_s
      file = m.filename
      name = m.name
      puts "\n==> Processando #{version} #{name} (#{file})"

      begin
        # Tentativa normal de subir a migration específica:
        ActiveRecord::Base.connection.transaction do
          ActiveRecord::Migrator.new(:up, [m], version).migrate
        end
        puts "   ✔ Applied (migrate:up)"
      rescue => e
        puts "   ! Falhou ao aplicar: #{e.class} - #{e.message}"
        # Heurística: se a estrutura já está presente, marcamos como aplicada
        begin
          if estrutura_presente_para?(name)
            ActiveRecord::Base.connection.execute("INSERT INTO schema_migrations (version) VALUES ('#{version}')")
            puts "   → Estrutura já existia. Marquei como aplicada (schema_migrations)."
          else
            puts "   → Estrutura NÃO confirmada. Deixe para corrigir manualmente."
          end
        rescue => e2
          puts "   ! Erro ao marcar como aplicada: #{e2.class} - #{e2.message}"
        end
      end
    end

    puts "\nPronto. Rode: bin/rails db:migrate:status RAILS_ENV=#{Rails.env}"
  end
end

# Heurísticas simples por nome da migration — ajuste se necessário.
def estrutura_presente_para?(migration_name)
  c = ActiveRecord::Base.connection
  case migration_name
  when /create_cotacoes/i
    c.table_exists?(:cotacoes)
  when /rename_cotacaos_to_cotacoes/i
    c.table_exists?(:cotacoes) || !c.table_exists?(:cotacaos)
  when /change_status_to_integer_in_fretes/i, /replace_status_string_with_integer_in_fretes/i, /adjust_status_in_fretes/i
    return false unless c.column_exists?(:fretes, :status)
    col = c.columns(:fretes).find { |x| x.name == "status" }
    !!(col && col.sql_type =~ /int/i)
  when /rename_carga_id_to_frete_id_in_cotacoes/i
    c.column_exists?(:cotacoes, :frete_id) || !c.column_exists?(:cotacoes, :carga_id)
  when /create_(leads|configs|modals|messages|propostas|historico_posts|historico_emails|historico_proposta)/i
    tbl = migration_name[/create_(\w+)/i, 1]
    c.table_exists?(tbl.to_s)
  when /add_(\w+)_to_(\w+)/i
    col, tbl = migration_name[/add_(\w+)_to_(\w+)/i, 1], migration_name[/add_(\w+)_to_(\w+)/i, 2]
    c.column_exists?(tbl.to_sym, col.to_sym)
  when /add_confirmable_to_clientes_and_transportadores/i
    clientes_ok = %i[confirmation_token confirmed_at confirmation_sent_at unconfirmed_email].all? { |col| c.column_exists?(:clientes, col) }
    transp_ok   = %i[confirmation_token confirmed_at confirmation_sent_at unconfirmed_email].all? { |col| c.column_exists?(:transportadores, col) }
    clientes_ok && transp_ok
  else
    # fallback conservador: não marca
    false
  end
end
