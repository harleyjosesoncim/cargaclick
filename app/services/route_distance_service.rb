# frozen_string_literal: true

require "net/http"
require "json"

class RouteDistanceService
  ORS_URL = "https://api.openrouteservice.org/v2/directions/driving-car"

  def self.distance_km(lat1, lon1, lat2, lon2)
    api_key = ENV["ORS_API_KEY"]
    return nil if api_key.blank?

    uri = URI(ORS_URL)
    req = Net::HTTP::Post.new(uri)
    req["Authorization"] = api_key
    req["Content-Type"]  = "application/json"

    req.body = {
      coordinates: [[lon1, lat1], [lon2, lat2]]
    }.to_json

    res = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
      http.request(req)
    end

    json = JSON.parse(res.body)
    meters = json.dig("routes", 0, "summary", "distance")
    meters ? (meters / 1000.0).round(2) : nil
  rescue StandardError => e
    Rails.logger.error("[ORS] #{e.class}: #{e.message}")
    nil
  end
end
