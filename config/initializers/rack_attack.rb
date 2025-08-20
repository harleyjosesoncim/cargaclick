# frozen_string_literal: true

# Garanta que a gem está carregada ANTES de abrir a classe
require "rack/attack"

# Só configura se a constante existir e se for produção
# (ou habilite em dev com RACK_ATTACK=1)
return unless defined?(Rack::Attack)
return unless Rails.env.production? || ENV["RACK_ATTACK"] == "1"

class Rack::Attack
  SIGN_IN_PATH = "/clientes/sign_in".freeze
  SIGN_UP_PATH = "/clientes".freeze # Devise registrations#create

  # Helpers para diferenças de versão (allowlist/safelist/whitelist; blocklist/blacklist)
  def self._allowlist(name, &blk)
    if respond_to?(:allowlist)      then allowlist(name, &blk)
    elsif respond_to?(:safelist)    then safelist(name, &blk)
    elsif respond_to?(:whitelist)   then whitelist(name, &blk)
    end
  end

  def self._blocklist(name, &blk)
    if respond_to?(:blocklist)      then blocklist(name, &blk)
    elsif respond_to?(:blacklist)   then blacklist(name, &blk)
    end
  end

  # Protege caso a sua versão (muito antiga) não tenha `throttle`
  def self._throttle(name, opts = {}, &blk)
    return unless respond_to?(:throttle)
    throttle(name, opts, &blk)
  end

  # Allowlist do healthcheck
  _allowlist("healthcheck-up") { |req| req.get? && req.path == "/up" }

  # Throttles
  _throttle("logins/ip",   limit: 10, period: 60)        { |req| req.ip if req.post? && req.path == SIGN_IN_PATH }
  _throttle("signups/ip",  limit: 5,  period: 3600)      { |req| req.ip if req.post? && req.path == SIGN_UP_PATH }
  _throttle("password/ip", limit: 5,  period: 600)       { |req| req.ip if req.post? && req.path == "/clientes/password" }

  # Blocklist opcional
  _blocklist("bad-ua") { |req| req.user_agent.to_s.strip.empty? }

  # Resposta 429 unificada (compatível com APIs antigas e novas)
  responder = lambda do |env|
    body = {
      error: "Throttle limit reached",
      match: env["rack.attack.match_type"],
      rule:  env["rack.attack.matched"],
      at:    Time.now.utc.iso8601
    }.to_json
    [429, { "Content-Type" => "application/json" }, [body]]
  end

  if respond_to?(:throttled_responder=)
    self.throttled_responder = responder
  else
    self.throttled_response  = responder
  end
end
