#!/bin/bash
set -e

echo "==> Rodando migrações dentro do container..."
bundle exec rake db:migrate || echo "⚠️  Falha nas migrations, mas continuando boot..."

echo "==> Subindo servidor Puma..."
exec "$@"

