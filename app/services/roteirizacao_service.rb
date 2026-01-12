# app/services/roteirizacao_service.rb
# Serviço de cálculo de rotas usando OpenRouteService (ORS)
# Offline-safe: nunca levanta exception para o fluxo principal

require "net/http"
require "json"
require "uri"

class RoteirizacaoService
  ORS_BASE_URL = "https://api.openrouteservice.org/v2/directions/driving-car"
  TIMEOUT_SEC  = 8

  Result = Struct.new(:distancia_km, :duracao_min, :erro, keyword_init: true)

  # --------------------------------------------------
  # API principal
  # --------------------------------------------------
  # origem  / destino: string (CEP ou endereço)
  #
  # Retorna Result:
  #   - distancia_km (Float ou nil)
  #   - duracao_min  (Float ou nil)
  #   - erro         (String ou nil)
  #
  def self.calcular(origem, destino)
    return Result.new(erro: "Origem ou destino ausente") if origem.blank? || destino.blank?

    begin
      origem_coord  = geocodificar(origem)
      destino_coord = geocodificar(destino)

      return Result.new(erro: "Falha na geocodificação") if origem_coord.nil? || destino_coord.nil?

      uri = URI.parse(ORS_BASE_URL)
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      http.read_timeout = TIMEOUT_SEC
      http.open_timeout = TIMEOUT_SEC

      request = Net::HTTP::Post.new(uri.request_uri)
      request["Authorization"] = api_key
      request["Content-Type"]  = "application/json"

      request.body = {
        coordinates: [
          origem_coord,
          destino_coord
        ]
      }.to_json

      response = http.request(request)

      return Result.new(erro: "ORS HTTP #{response.code}") unless response.is_a?(Net::HTTPSuccess)

      data = JSON.parse(response.body)

      route = data.dig("features", 0, "properties", "segments", 0)

      distancia_m  = route&.dig("distance")
      duracao_sec  = route&.dig("duration")

      return Result.new(erro: "Resposta ORS inválida") if distancia_m.nil?

      Result.new(
        distancia_km: (distancia_m.to_f / 1000).round(2),
        duracao_min:  duracao_sec ? (duracao_sec.to_f / 60).round(1) : nil
      )

    rescue StandardError => e
      Rails.logger.warn("[RoteirizacaoService] #{e.class}: #{e.message}")
      Result.new(erro: "Erro interno ao calcular rota")
    end
  end

  # --------------------------------------------------
  # Geocodificação simples (ORS)
  # --------------------------------------------------
  def self.geocodificar(endereco)
    return nil if endereco.blank?

    uri = URI.parse("https://api.openrouteservice.org/geocode/search")
    uri.query = URI.encode_www_form(
      api_key: api_key,
      text: endereco,
      size: 1
    )

    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true
    http.read_timeout = TIMEOUT_SEC
    http.open_timeout = TIMEOUT_SEC

    response = http.get(uri.request_uri)

    return nil unless response.is_a?(Net::HTTPSuccess)

    data = JSON.parse(response.body)
    coords = data.dig("features", 0, "geometry", "coordinates")

    return nil unless coords.is_a?(Array) && coords.size == 2

    coords # [lon, lat]
  rescue StandardError => e
    Rails.logger.warn("[RoteirizacaoService][Geocode] #{e.message}")
    nil
  end

  # --------------------------------------------------
  # API Key
  # --------------------------------------------------
  def self.api_key
    ENV["ORS_API_KEY"]
  end
end
