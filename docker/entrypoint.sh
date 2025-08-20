#!/usr/bin/env bash
set -Eeuo pipefail

echo "===> Boot CargaClick (env: ${RAILS_ENV:-production})"

export RAILS_ENV=${RAILS_ENV:-production}
export RACK_ENV=${RACK_ENV:-$RAILS_ENV}
export NODE_ENV=${NODE_ENV:-production}

# Falhar cedo se faltar secrets importantes
: "${SECRET_KEY_BASE:?SECRET_KEY_BASE is required}"
# Use somente se você usa credentials:
: "${RAILS_MASTER_KEY:?RAILS_MASTER_KEY is required}"

echo "===> DB migrate"
bundle exec rails db:migrate

# Precompila assets com ENVs reais (idempotente)
if ! ls public/assets/manifest-*.json >/dev/null 2>&1; then
  echo "===> Assets precompile"
  bundle exec rails assets:precompile
else
  echo "===> Assets já presentes, pulando precompile"
fi

echo "===> Start Puma"
exec "$@"
