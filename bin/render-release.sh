#!/usr/bin/env bash
set -o errexit

echo "==> Rodando migrations no ambiente de produção..."
bundle exec rails db:migrate

echo "==> Limpando schema antigo (se houver)..."
bundle exec rails db:schema:dump
