# script/sanity_check.rb
# frozen_string_literal: true

require "active_record"
require "net/smtp"

puts "=== SANITY CHECK: CARGACLICK ==="

# ============================================================
# 1) Banco de Dados
# ============================================================
begin
  puts "[DB] Testando conexão..."
  version = ActiveRecord::Base.connection.execute("SELECT version();").first
  puts "[DB] OK ✅ -> #{version}"
rescue => e
  puts "[DB] ERRO ❌ -> #{e.class}: #{e.message}"
end

# ============================================================
# 2) Mercado Pago
# ============================================================
begin
  puts "[MP] Testando token..."
  require "mercadopago"
  sdk = Mercadopago::SDK.new(ENV["MP_ACCESS_TOKEN"])
  user = sdk.get("/users/me")
  if user["response"]
    puts "[MP] OK ✅ -> Usuário: #{user['response']['nickname']}"
  else
    puts "[MP] ERRO ❌ -> resposta inválida: #{user.inspect}"
  end
rescue => e
  puts "[MP] ERRO ❌ -> #{e.class}: #{e.message}"
end

# ============================================================
# 3) SMTP
# ============================================================
begin
  puts "[SMTP] Testando configs..."
  smtp_address = ENV["SMTP_ADDRESS"]
  smtp_port    = ENV["SMTP_PORT"] || 587
  raise "Variáveis SMTP não configuradas" unless smtp_address

  Net::SMTP.start(smtp_address, smtp_port.to_i, ENV["SMTP_DOMAIN"]) do |smtp|
    puts "[SMTP] OK ✅ -> Conseguiu abrir conexão (não enviou email)"
  end
rescue => e
  puts "[SMTP] ERRO ❌ -> #{e.class}: #{e.message}"
end

puts "=== SANITY CHECK FINALIZADO ==="
