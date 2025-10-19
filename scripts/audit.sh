#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

RAILS_ENV="${RAILS_ENV:-production}"

# Carrega .env (KEY=VALUE) se existir
if [ -f .env ]; then
  export $(grep -vE '^\s*#' .env | awk 'NF' | sed 's/\r$//')
fi

ensure_db_url() {
  if [ -z "${DATABASE_URL:-}" ] && [ -f config/database.yml ]; then
    URL=$(ruby -ryaml -rerb -e 'y=YAML.safe_load(ERB.new(File.read("config/database.yml")).result, aliases: true); puts (y["production"] && y["production"]["url"]).to_s rescue ""')
    [ -n "$URL" ] && export DATABASE_URL="$URL"
  fi
  if [ -z "${DATABASE_URL:-}" ]; then
    echo "ERRO: defina DATABASE_URL (use FQDN + sslmode=require). Ex.:"
    echo "export DATABASE_URL='postgres://USER:PASS@dpg-xxx.oregon-postgres.render.com:5432/DB?sslmode=require'"
    exit 1
  fi
}

RANGE="${1:-semana}"
ensure_db_url
export RANGE

bundle exec rails runner - <<'RUBY'
range = (ENV['RANGE'] || 'semana').downcase
now   = Time.current
since =
  case range
  when 'hoje','today'      then now.beginning_of_day
  when 'semana','week'     then 7.days.ago.beginning_of_day
  when 'mes','mês','month' then 30.days.ago.beginning_of_day
  else
    if range =~ /\A(\d+)d\z/
      $1.to_i.days.ago.beginning_of_day
    else
      7.days.ago.beginning_of_day
    end
  end

def model?(name)
  Object.const_defined?(name) && Object.const_get(name) < ActiveRecord::Base
end

def recent_logins(name, since)
  return [] unless model?(name)
  k = Object.const_get(name)
  cols = k.column_names
  ts  = cols.include?('current_sign_in_at') ? 'current_sign_in_at' :
        (cols.include?('last_sign_in_at') ? 'last_sign_in_at' : nil)
  return [] unless ts
  k.where("#{ts} >= ?", since).order("#{ts} desc").limit(10).pluck(:id, :email, ts)
end

def count_created(name, since, now)
  return 0 unless model?(name)
  Object.const_get(name).where(created_at: since..now).count
end

frete_klass = model?('Frete') ? Frete : nil
fretes_criados = frete_klass ? frete_klass.where(created_at: since..now).count : 0
status_counts  = frete_klass ? frete_klass.where(updated_at: since..now).group(:status).count : {}

avaliacoes = count_created('Avaliacao', since, now)
novos_clientes = count_created('Cliente', since, now)
novos_transportadores = count_created('Transportador', since, now)

clientes_login      = recent_logins('Cliente', since)
transportadores_login = recent_logins('Transportador', since)
admins_login        = recent_logins('AdminUser', since)

recent_fretes      = frete_klass ? frete_klass.where(created_at: since..now).order(created_at: :desc).limit(10).pluck(:id,:status,:created_at) : []
recent_fretes_upd  = frete_klass ? frete_klass.where(updated_at: since..now).order(updated_at: :desc).limit(10).pluck(:id,:status,:updated_at) : []

puts "=== AUDITORIA CARGACLICK (#{since.strftime('%Y-%m-%d %H:%M')} .. #{now.strftime('%Y-%m-%d %H:%M')}) ==="
puts
puts "[MOVIMENTO]"
puts "  Fretes criados:          #{fretes_criados}"
puts "  Atualizações por status: #{status_counts.map{|k,v| "#{k}=#{v}"}.join(', ').presence || '—'}"
puts "  Avaliações novas:        #{avaliacoes}"
puts "  Novos clientes:          #{novos_clientes}"
puts "  Novos transportadores:   #{novos_transportadores}"
puts
puts "[ACESSOS - últimos logins no período]"
puts "  Clientes:"
clientes_login.each{|id,email,ts| puts "    ##{id} <#{email}> @ #{ts}" }
puts "  Transportadores:"
transportadores_login.each{|id,email,ts| puts "    ##{id} <#{email}> @ #{ts}" }
puts "  Admins:"
admins_login.each{|id,email,ts| puts "    ##{id} <#{email}> @ #{ts}" }
puts
puts "[Fretes criados (top 10)]"
recent_fretes.each{|id,st,ts| puts "    ##{id} status=#{st} criado_em=#{ts}" }
puts "[Fretes atualizados (top 10)]"
recent_fretes_upd.each{|id,st,ts| puts "    ##{id} status=#{st} atualizado_em=#{ts}" }
RUBY
