# sobrescrever (se preferir via terminal)
cat > config/initializers/rack_attack.rb <<'RUBY'
# frozen_string_literal: true

if defined?(Rack::Attack)
  class Rack::Attack
    throttle('req/ip',
             limit: ENV.fetch('RACK_ATTACK_REQ_LIMIT', '120').to_i,
             period: 60) { |req| req.ip }

    throttle('logins/email',
             limit: ENV.fetch('RACK_ATTACK_LOGIN_LIMIT', '5').to_i,
             period: 20) do |req|
      if req.path == '/clientes/sign_in' && req.post?
        (req.params.dig('user', 'email') || '').downcase
      end
    end

    safelist('allow-healthcheck') { |req| req.path == '/up' }
    blocklist('bad-uas') { |req| req.user_agent.to_s =~ /(sqlmap|nikto|nmap|dirbuster)/i }

    self.throttled_responder = lambda do |_request|
      [429, { 'Content-Type' => 'application/json' }, [{ error: 'Too many requests' }.to_json]]
    end
  end
end
RUBY

# checar sintaxe Ruby do arquivo
ruby -c config/initializers/rack_attack.rb

# (opcional) checar boot da app em console
bin/rails r 'puts "Rack::Attack definido em prod? #{Rails.env} -> #{defined?(Rack::Attack).inspect}"'
