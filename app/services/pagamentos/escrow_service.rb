# frozen_string_literal: true

# Orquestra o fluxo de escrow do CargaClick.
#
# Regras:
# - Após aprovação do pagamento no gateway, o Pagamento entra em status "escrow".
# - Quando a entrega é concluída e o cliente (ou admin) confirma, o sistema
#   executa o repasse (Pix) ao transportador e muda para "liberado".

module Pagamentos
  class EscrowService
    Result = Struct.new(:success?, :pagamento, :error, keyword_init: true)

    def initialize(payout_service: PixPayoutService.new)
      @payout_service = payout_service
    end

    def colocar_em_escrow!(pagamento, txid: nil)
      raise ArgumentError, "pagamento inválido" unless pagamento.is_a?(Pagamento)

      attrs = { status: "escrow" }
      attrs[:txid] = txid if txid.present? && pagamento.has_attribute?(:txid)
      attrs[:escrow_at] = Time.current if pagamento.has_attribute?(:escrow_at)
      pagamento.update!(attrs)

      Result.new(success?: true, pagamento: pagamento)
    rescue StandardError => e
      Result.new(success?: false, pagamento: pagamento, error: e.message)
    end

    def liberar!(pagamento, actor: nil, motivo: "entrega_confirmada")
      raise ArgumentError, "pagamento inválido" unless pagamento.is_a?(Pagamento)

      unless pagamento.status == "escrow"
        return Result.new(success?: false, pagamento: pagamento, error: "Pagamento não está em escrow")
      end

      payout = @payout_service.transferir!(pagamento)

      if payout.success?
        attrs = {
          status: "liberado",
          payout_status: "sucesso",
          payout_txid: payout.payout_txid
        }
        attrs[:liberado_at] = Time.current if pagamento.has_attribute?(:liberado_at)
        attrs[:payout_error] = nil if pagamento.has_attribute?(:payout_error)

        pagamento.update!(attrs)

        Rails.logger.info("[ESCROW] liberado pagamento_id=#{pagamento.id} motivo=#{motivo} actor=#{actor_label(actor)}")
        Result.new(success?: true, pagamento: pagamento)
      else
        attrs = { payout_status: "falha" }
        attrs[:payout_error] = payout.error if pagamento.has_attribute?(:payout_error)
        pagamento.update!(attrs)

        Result.new(success?: false, pagamento: pagamento, error: payout.error)
      end
    rescue StandardError => e
      Result.new(success?: false, pagamento: pagamento, error: e.message)
    end

    private

    def actor_label(actor)
      return "N/A" if actor.blank?
      return actor.email if actor.respond_to?(:email) && actor.email.present?
      actor.to_s
    end
  end
end
