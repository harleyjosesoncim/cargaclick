#!/usr/bin/env bash
set -euo pipefail

# Uso: ./scripts/render-sync-env.sh [caminho_do_env] [service_name_ou_id]
ENV_FILE="${1:-.env.local}"
SERVICE_INPUT="${2:-${RENDER_SERVICE:-}}"

# 1) Checagens básicas
if ! command -v render >/dev/null 2>&1; then
  echo "❌ Precisa do Render CLI. Instale e faça login: https://render.com/docs/cli"
  exit 1
fi

if [[ ! -f "$ENV_FILE" ]]; then
  echo "❌ Arquivo $ENV_FILE não encontrado."
  exit 1
fi

# 2) Descobrir serviço (ordem: arg -> env -> render.yaml)
discover_service() {
  local s="${SERVICE_INPUT:-}"
  if [[ -n "${s:-}" ]]; then
    echo "$s"
    return
  fi

  # tenta pegar do render.yaml (primeiro service.name encontrado)
  if [[ -f "render.yaml" || -f "render.yml" ]]; then
    local f
    f="$( [[ -f render.yaml ]] && echo render.yaml || echo render.yml )"
    # pega a primeira linha com "name:" sob um bloco "services:"
    local in_services=0
    while IFS= read -r line; do
      [[ "$line" =~ ^[[:space:]]*services: ]] && in_services=1 && continue
      if (( in_services )); then
        if [[ "$line" =~ ^[[:space:]]*name:[[:space:]]*(.+)$ ]]; then
          echo "${BASH_REMATCH[1]}" | xargs
          return
        fi
      fi
    done < "$f"
  fi

  # fallback
  echo ""
}

SERVICE="$(discover_service)"

if [[ -z "$SERVICE" ]]; then
  echo "❌ Informe o serviço: ./scripts/render-sync-env.sh .env.local <service-name-ou-srv-id>"
  exit 1
fi

echo "→ Sincronizando variáveis de '$ENV_FILE' para o serviço '${SERVICE}'…"

# 3) Não subir variáveis gerenciadas/locais
EXCLUDE_KEYS_REGEX='^(DATABASE_URL|RAILS_ENV|RACK_ENV)$'

# 4) Função que tenta múltiplas sintaxes do CLI
set_kv() {
  local service="$1" key="$2" val="$3"

  # tenta KEY=VALUE (sem --service)
  if render env set "$service" "$key=$val" --force >/dev/null 2>&1; then
    return 0
  fi
  # tenta KEY VALUE (sem --service)
  if render env set "$service" "$key" "$val" --force >/dev/null 2>&1; then
    return 0
  fi
  # tenta com --service
  if render env set --service "$service" "$key" "$val" --force >/dev/null 2>&1; then
    return 0
  fi
  if render env set --service "$service" "$key=$val" --force >/dev/null 2>&1; then
    return 0
  fi

  return 1
}

# 5) Ler o .env (sem perder valores vazios; ignora comentários/linhas em branco)
while IFS= read -r LINE || [[ -n "$LINE" ]]; do
  [[ "$LINE" =~ ^[[:space:]]*$ ]] && continue
  [[ "$LINE" =~ ^[[:space:]]*# ]] && continue

  KEY="${LINE%%=*}"
  VALUE="${LINE#*=}"

  # trim da chave e do valor
  KEY="$(echo -n "$KEY" | xargs)"
  VALUE="${VALUE#"${VALUE%%[![:space:]]*}"}"
  VALUE="${VALUE%"${VALUE##*[![:space:]]}"}"

  [[ -z "$KEY" ]] && continue
  if [[ "$KEY" =~ $EXCLUDE_KEYS_REGEX ]]; then
    echo "· pulando $KEY"
    continue
  fi

  # remove aspas ao redor (mas mantém conteúdo interno)
  if [[ "$VALUE" =~ ^\".*\"$ || "$VALUE" =~ ^\'.*\'$ ]]; then
    VALUE="${VALUE:1:-1}"
  fi

  if set_kv "$SERVICE" "$KEY" "$VALUE"; then
    echo "✓ $KEY"
  else
    echo "⚠️  falhou ao enviar $KEY"
  fi
done < "$ENV_FILE"

echo "✔ Concluído. Se quiser redeploy:  render deploy \"$SERVICE\""
