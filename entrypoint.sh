#!/usr/bin/env bash
set -e

echo "🚀 Iniciando setup do banco..."

# Detecta se o banco está vazio (só tem migrations internas)
TABLES=$(bundle exec rails runner -e production 'puts ActiveRecord::Base.connection.tables.grep_v(/^(schema_migrations|ar_internal_metadata)$/).any?' || echo "false")

if [ "$TABLES" = "false" ]; then
  echo "📦 Banco vazio, carregando schema.rb..."
  bundle exec rails db:schema:load RAILS_ENV=production
  bundle exec rails db:seed RAILS_ENV=production || true
else
  echo "🔄 Banco já tem tabelas, aplicando migrations..."
  bundle exec rails db:migrate RAILS_ENV=production || true
fi

echo "✅ Banco pronto. Subindo servidor Puma..."
exec bundle exec puma -C config/puma.rb
