#!/usr/bin/env bash
# bin/render-build.sh
# Build hook para Render (Rails + Docker)

set -o errexit  # para se qualquer comando falhar

echo "===> Instalando gems..."
bundle install --jobs=4 --retry=5

echo "===> Instalando pacotes JS..."
yarn install --frozen-lockfile || true

echo "===> Pré-compilando assets..."
bundle exec rails assets:precompile
bundle exec rails assets:clean

# Migrações de banco
# 🔹 Free plan → melhor rodar as migrations no preDeploy do render.yaml
# 🔹 Paid plan → pode rodar aqui sem problema
if [ "$RUN_MIGRATIONS" = "true" ]; then
  echo "===> Rodando migrações do banco..."
  bundle exec rails db:migrate
fi

echo "===> Build concluído!"
