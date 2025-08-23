# config/initializers/rack_attack.rb
# frozen_string_literal: true

return unless defined?(Rack::Attack)

# Habilita por padrão só em produção (pode forçar via ENV)
enabled_default = Rails.env.production? ? "true" : "false"
enabled = ENV.fetch("RACK_ATTACK_ENABLED", enabled_default) == "true"
Rack::Attack.enabled = enabled

# Store para contadores (se não houver Redis, usa memória local)
Rack::Attack.cache.store ||= ActiveSupport::Cache::MemoryStore.new

if enabled
  # Limites padrão (ajustáveis por ENV)
  req_limit = Integer(ENV.fetch("RACK_ATTACK_REQ_LIMIT", "120"))
  period    = Integer(ENV.fetch("RACK_ATTACK_PERIOD", "60")) # segundos

  # Safelists úteis
  Rack::Attack.safelist("healthcheck") { |req| req.path == "/up" }
  Rack::Attack.safelist("assets")      { |req| req.path.start_with?("/assets/") }
  Rack::Attack.safelist("robots")      { |req| req.path == "/robots.txt" }
  Rack::Attack.safelist("favicon")     { |req| req.path == "/favicon.ico" }

  # Throttle básico por IP
  Rack::Attack.throttle("requests/ip", limit: req_limit, period: period) { |req| req.ip }
end

# Resposta padrão quando estoura o limite (API nova: throttled_responder)
Rack::Attack.throttled_responder = lambda do |request|
  match = request.env["rack.attack.match_data"] || {}
  headers = {
    "Content-Type" => "application/json",
    "Retry-After"  => (match[:period] || 60).to_s
  }
  body = {
    error:  "Too Many Requests",
    limit:  match[:limit],
    period: match[:period],
    count:  match[:count]
  }.to_json

  [429, headers, [body]]
end
