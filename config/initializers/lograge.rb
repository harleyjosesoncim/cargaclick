# (cole aqui o conteúdo da seção lograge.rb)
# frozen_string_literal: true
Rails.application.configure do
  # Ativa Lograge só em produção
  config.lograge.enabled = Rails.env.production?

  # JSON (mais fácil de consultar/agregar na plataforma)
  config.lograge.formatter = Lograge::Formatters::Json.new

  # Reduz barulho de parâmetros padrões
  config.lograge.ignore_actions = ["Rails::HealthController#show"] # /up

  # Payload extra por request (sem vazar segredos)
  config.lograge.custom_payload do |controller|
    {
      ip: controller.request.remote_ip,
      ua: controller.request.user_agent,
      cliente_id: controller.try(:current_cliente)&.id,
      transportador_id: controller.try(:current_transportador)&.id
    }
  end

  # Inclui params (já respeita filtros de FilterParameterLogging)
  config.lograge.custom_options = lambda do |event|
    {
      time: event.time.iso8601,
      request_id: event.payload[:request_id],
      params: event.payload[:params].except("controller", "action", "format", "utf8")
    }
  end
end
