# Usuário master Cliente
Cliente.find_or_create_by!(email: "master.cliente@cargaclick.com") do |c|
  c.nome = "Master Cliente"
  c.password = "123456"
  c.password_confirmation = "123456"
  c.confirmed_at = Time.now
end

# Usuário master Transportador
Transportador.find_or_create_by!(email: "master.transportador@cargaclick.com") do |t|
  t.nome = "Master Transportador"
  t.password = "123456"
  t.password_confirmation = "123456"
  t.tipo_veiculo = "Caminhão"
  t.confirmed_at = Time.now
end
# Usuário master Admin
