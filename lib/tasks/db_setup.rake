# lib/tasks/db_setup.rake
namespace :db do
  desc "Roda migrations e seeds em produção de forma segura"
  task setup_prod: :environment do
    puts "🚀 Rodando migrations..."
    Rake::Task["db:migrate"].invoke

    puts "🌱 Rodando seeds..."
    Rake::Task["db:seed"].invoke

    puts "✅ Banco atualizado com migrations e seeds"
  end
end
