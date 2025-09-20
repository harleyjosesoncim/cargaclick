#!/bin/bash
set -e

echo "👉 Marcando migrations específicas como aplicadas no banco de produção..."

RAILS_ENV=production bin/rails runner "ActiveRecord::Base.connection.execute(%q{
  INSERT INTO schema_migrations (version) VALUES
  ('20250910200000'),
  ('20250910203001')
  ON CONFLICT DO NOTHING;
})"

echo "✅ Migrations marcadas como aplicadas com sucesso!"
