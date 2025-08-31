#!/usr/bin/env bash
set -o errexit

echo "===> Rodando migrations no ambiente de produção..."
bundle exec rails db:migrate
echo "===> Migrations concluídas com sucesso ✅"
