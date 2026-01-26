# frozen_string_literal: true

module Pagamentos
  class AutoLiberarEscrowJob < ApplicationJob
    queue_as :default

    def perform
      Pagamento
        .includes(:frete, :cliente, :transportador)
        .where(status: "escrow")
        .find_each do |pagamento|

        next unless elegivel?(pagamento)

        result = Pagamentos::EscrowService.new.liberar!(
          pagamento,
          actor: "sistema",
          motivo: "auto_liberacao_regra"
        )

        log_result(pagamento, result)
      end
    end

    private

    def elegivel?(pagamento)
      contrato = ContratoDigital.find_by(frete_id: pagamento.frete_id)

      return false if contrato.blank?
      return false unless contrato.status == "aceito"
      return false unless pagamento.frete.entrega_confirmada?
      return false if pagamento.frete.em_disputa?
      return false if expirado?(pagamento)

      true
    end

    def expirado?(pagamento)
      pagamento.created_at < 30.days.ago
    end

    def log_result(pagamento, result)
      Rails.logger.info(
        "[AUTO-ESCROW] pagamento=#{pagamento.id} success=#{result.success?} error=#{result.error}"
      )
    end
  end
end
