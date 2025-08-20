#!/usr/bin/env bash
set -e

# Prepara o DB (cria/migra) se DATABASE_URL estiver configurado
if [ -n "${DATABASE_URL}" ]; then
  echo "→ Preparando banco (db:prepare)..."
  bundle exec rails db:prepare
fi

exec "$@"
