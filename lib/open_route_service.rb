require 'net/http'
require 'json'

class OpenRouteService
  API_KEY = ENV['ORS_API_KEY'] || 'SUA_CHAVE_AQUI'

  def self.calcular_distancia(origem, destino)
    uri = URI("https://api.openrouteservice.org/v2/directions/driving-car")
    headers = {
      "Authorization" => API_KEY,
      "Content-Type" => "application/json"
    }

    body = {
      coordinates: [origem.reverse, destino.reverse] # ORS espera [lon, lat]
    }.to_json

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    request = Net::HTTP::Post.new(uri.request_uri, headers)
    request.body = body

    response = http.request(request)

    if response.code == "200"
      data = JSON.parse(response.body)
      distancia_metros = data["features"][0]["properties"]["segments"][0]["distance"]
      (distancia_metros / 1000.0).round(2)
    else
      puts "Erro ORS: #{response.code} #{response.body}"
      nil
    end
  rescue => e
    puts "Erro na chamada ORS: #{e.message}"
    nil
  end
end
