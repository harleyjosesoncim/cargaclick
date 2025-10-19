#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

RAILS_ENV="${RAILS_ENV:-production}"

# carrega .env se existir (chaves no formato KEY=VALUE)
if [ -f .env ]; then
  # suporta linhas com espaços e ignora comentários
  export $(grep -vE '^\s*#' .env | xargs -d '\n' -I{} bash -lc 'k="${{}%%=*}"; v="${{}#*=}"; printf "%s=%q\n" "$k" "$v"')
fi

ensure_db_url() {
  if [ -z "${DATABASE_URL:-}" ]; then
    if [ -f config/database.yml ]; then
      URL=$(ruby -ryaml -rerb -e 'y=YAML.safe_load(ERB.new(File.read("config/database.yml")).result, aliases: true); puts (y["production"] && y["production"]["url"]).to_s rescue ""')
      [ -n "$URL" ] && export DATABASE_URL="$URL"
    fi
  fi
  if [ -z "${DATABASE_URL:-}" ]; then
    echo "ERRO: DATABASE_URL não definido. Exemplo:"
    echo "export DATABASE_URL='postgres://USER:PASS@dpg-XXX.oregon-postgres.render.com:5432/DBNAME?sslmode=require'"
    exit 1
  fi
}

list_admins() {
  ensure_db_url
  bundle exec rails runner "puts(AdminUser.pluck(:id,:email).map{|id,e| \"\#{id} <\#{e}>\"}.join(\"\\n\"))"
}

create_admin() {
  ensure_db_url
  local email="${1:-admin@cargaclick.com}"
  local pwd="${2:-TroqueMeAgora!123}"
  bundle exec rails runner "u=AdminUser.find_or_initialize_by(email:'$email'); u.password='$pwd'; u.password_confirmation='$pwd'; u.save!; puts \"OK -> \#{u.email}\""
}

reset_password() {
  ensure_db_url
  local email="${1:?Informe o e-mail}"
  local pwd="${2:?Informe a nova senha}"
  bundle exec rails runner "u=AdminUser.find_or_create_by(email:'$email'); u.password='$pwd'; u.password_confirmation='$pwd'; u.save!; puts \"Senha resetada -> \#{u.email}\""
}

routes_admin() {
  bundle exec rails routes | grep -E '^\s*admin' || true
}

db_check() {
  ensure_db_url
  bundle exec rails db:version
}

stats() {
  ensure_db_url
  bundle exec rails runner '
    out = {
      clientes: (defined?(Cliente) ? Cliente.count : 0),
      transportadores: (defined?(Transportador) ? Transportador.count : 0),
      fretes: (defined?(Frete) ? Frete.count : 0),
      avaliacoes: (defined?(Avaliacao) ? Avaliacao.count : 0)
    }
    puts out.map{|k,v| "#{k}: #{v}"}.join("\n")
  '
}

case "${1:-help}" in
  list)       list_admins ;;
  create)     create_admin "${2:-}" "${3:-}" ;;
  reset)      reset_password "${2:-}" "${3:-}" ;;
  routes)     routes_admin ;;
  db:check)   db_check ;;
  stats)      stats ;;
  help|*)     echo "Uso: scripts/admin.sh [list|create EMAIL SENHA|reset EMAIL SENHA|routes|db:check|stats]";;
esac
