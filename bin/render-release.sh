#!/usr/bin/env bash
# bin/render-release.sh
# Script de release para Render (Rails + Docker)
# Executa migrations com rollback em caso de falha

set -o errexit  # encerra ao primeiro erro
set -o pipefail # falha também em pipes

echo "===> 🚀 Iniciando release do CargaClick..."

# Função de log
log() {
  echo "[RELEASE] $1"
}

# Função para rollback
rollback() {
  log "❌ Erro detectado. Tentando rollback..."
  bundle exec rails db:rollback STEP=1 || log "⚠️ Nenhuma migration para reverter."
  exit 1
}

# Garantir que estamos em produção
export RAILS_ENV=production

# Rodar migrations
log "📂 Rodando migrations..."
if bundle exec rails db:migrate; then
  log "✅ Migrations concluídas com sucesso!"
else
  rollback
fi

# Opcional: limpar assets antigos (se usar Sprockets/Tailwind)
if [ -d "public/assets" ]; then
  log "🧹 Limpando assets antigos..."
  bundle exec rails assets:clean || log "⚠️ Falha ao limpar assets, prosseguindo."
fi

log "🎉 Release concluído com sucesso!"
