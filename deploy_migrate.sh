#!/bin/bash
set -e

# Nome ou ID do serviço no Render (ajuste se necessário)
SERVICE_NAME="cargaclick"

echo "🔑 Fazendo login no Render..."
render login

echo "🚀 Rodando migrations em produção para $SERVICE_NAME..."
render jobs:create \
  --service $SERVICE_NAME \
  --command "bundle exec rails db:migrate"

echo "📋 Conferindo status das migrations..."
render jobs:create \
  --service $SERVICE_NAME \
  --command "bundle exec rails db:migrate:status"

echo "✅ Finalizado com sucesso!"
