# Clientes de exemplo (Devise)
clientes = [
  { email: "ana@exemplo.com",  password: "senha123" },
  { email: "bruno@exemplo.com", password: "senha123" },
  { email: "carla@exemplo.com", password: "senha123" }
]

clientes.each do |attrs|
  Cliente.find_or_create_by!(email: attrs[:email]) do |c|
    c.password = attrs[:password]
    c.password_confirmation = attrs[:password]
  end
end
puts "[seeds] Clientes criados/garantidos: #{clientes.map { _1[:email] }.join(', ')}"
