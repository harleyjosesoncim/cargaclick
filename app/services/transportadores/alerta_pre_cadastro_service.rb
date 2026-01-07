# frozen_string_literal: true

module Transportadores
  class AlertaPreCadastroService
    ALERT_INTERVAL = 48.hours

    def self.call
      Transportador
        .where(activated_at: nil)
        .where.not(telefone: [nil, ""])
        .where("last_alert_at IS NULL OR last_alert_at < ?", ALERT_INTERVAL.ago)
        .find_each do |transportador|

        new(transportador).alertar!
      end
    end

    def initialize(transportador)
      @transportador = transportador
    end

    def alertar!
      enviar_alerta
      marcar_alerta
    rescue StandardError => e
      Rails.logger.error("[Transportadores::AlertaPreCadastro] #{@transportador.id} — #{e.message}")
    end

    private

    def enviar_alerta
      Rails.logger.info <<~LOG
        🔔 ALERTA TRANSPORTADOR (PRÉ-CADASTRO)
        Nome: #{@transportador.nome}
        Telefone: #{@transportador.telefone}
        Link: #{activation_link}
      LOG
    end

    def marcar_alerta
      @transportador.update_column(:last_alert_at, Time.current)
    end

    def activation_link
      "#{ENV.fetch('APP_HOST', 'https://www.cargaclick.com.br')}/transportadores/ativar/#{@transportador.id}"
    end
  end
end
