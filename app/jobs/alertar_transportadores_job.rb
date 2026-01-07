class AlertarTransportadoresJob < ApplicationJob
  queue_as :default

  def perform
    Transportadores::AlertaPreCadastroService.call
  end
end
