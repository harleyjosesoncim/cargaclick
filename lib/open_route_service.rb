
require 'net/http'
require 'json'

class OpenRouteService
  API_KEY = ENV['ORS_API_KEY']

  def self.calcular_distancia(origem, destino)
    # Simulação mockada, substitua por integração real com ORS
    # Aqui pode converter CEP -> coordenadas com Nominatim ou outro serviço
    # Depois usa ORS para rota real
    rand(10..100) # Retorna uma distância fictícia entre 10 e 100 km
  end
end
