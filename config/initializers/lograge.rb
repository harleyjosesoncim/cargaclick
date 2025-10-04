# config/initializers/lograge.rb
# frozen_string_literal: true

Rails.application.configure do
  # Ativa e configura somente em produção
  next unless Rails.env.production?

  config.lograge.enabled                 = true
  config.lograge.keep_original_rails_log = false
  config.lograge.formatter               = Lograge::Formatters::Json.new
  config.lograge.ignore_actions          = ["Rails::HealthController#show"] # /up

  # Campos extras por request (não inclui segredos)
  config.lograge.custom_payload do |controller|
    {
      host: controller.request.host,
      ip:   controller.request.remote_ip,
      ua:   controller.request.user_agent,
      admin_id:         controller.try(:current_admin_user)&.id,
      cliente_id:       controller.try(:current_cliente)&.id,
      transportador_id: controller.try(:current_transportador)&.id
    }
  end

  # Corrige event.time (Float ou Time) e higieniza params
  config.lograge.custom_options = lambda do |event|
    t = event.time.is_a?(Time) ? event.time : Time.at(event.time.to_f)
    params = (event.payload[:params] || {}).dup
    params.except!("controller", "action", "format", "utf8")

    {
      time:       t.utc.iso8601,
      request_id: event.payload[:request_id],
      params:     params
    }
  end
end

