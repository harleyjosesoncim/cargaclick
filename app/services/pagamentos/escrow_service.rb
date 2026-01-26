# frozen_string_literal: true

# ==========================================================
# Pagamentos::EscrowService
#
# Orquestra o fluxo financeiro de escrow do CargaClick.
#
# PRINCÍPIOS DE PRODUÇÃO:
# - Estado é soberano (não força transições inválidas)
# - Idempotência defensiva
# - Auditoria completa (logs + timestamps)
# - Falha segura (nunca libera sem confirmação)
# - Nenhuma regra de negócio em controller
#
# FLUXO:
# pendente -> escrow -> liberado
#
# O pagamento SÓ é liberado após:
# - ContratoDigital aceito
# - Confirmação explícita (cliente/admin)
# ==========================================================

module Pagamentos
  class EscrowService
    Result = Struct.new(
      :success?,
      :pagamento,
      :error,
      :metadata,
      keyword_init: true
    )

    PagamentoAuditoria.create!(
  pagamento: pagamento,
  acao: "liberacao",
  ator: actor_label(actor),
  motivo: motivo
)


    def initialize(
      payout_service: PixPayoutService.new,
      logger: Rails.logger
    )
      @payout_service = payout_service
      @logger = logger
    end

    # ------------------------------------------------------
    # COLOCAR EM ESCROW
    # ------------------------------------------------------
    def colocar_em_escrow!(pagamento, txid: nil)
      validar_pagamento!(pagamento)

      return sucesso(pagamento, info: "já_em_escrow") if pagamento.status == "escrow"

      unless %w[pendente confirmado].include?(pagamento.status)
        return falha(pagamento, "Estado inválido para escrow: #{pagamento.status}")
      end

      pagamento.with_lock do
        attrs = { status: "escrow" }
        attrs[:txid]      = txid if txid.present? && pagamento.has_attribute?(:txid)
        attrs[:escrow_at] = Time.current if pagamento.has_attribute?(:escrow_at)

        pagamento.update!(attrs)
      end

      log_info("Pagamento colocado em escrow", pagamento)

      sucesso(pagamento)
    rescue StandardError => e
      log_error("Erro ao colocar em escrow", pagamento, e)
      falha(pagamento, e.message)
    end

    # ------------------------------------------------------
    # LIBERAR ESCROW (PIX)
    # ------------------------------------------------------
    def liberar!(pagamento, actor:, motivo: "entrega_confirmada")
      validar_pagamento!(pagamento)

      return sucesso(pagamento, info: "já_liberado") if pagamento.status == "liberado"

      unless pagamento.status == "escrow"
        return falha(pagamento, "Pagamento não está em escrow")
      end

      unless contrato_aceito?(pagamento)
        return falha(pagamento, "Contrato digital não aceito")
      end

      pagamento.with_lock do
        payout = @payout_service.transferir!(pagamento)

        if payout.success?
          attrs = {
            status:         "liberado",
            payout_status:  "sucesso",
            payout_txid:    payout.payout_txid
          }

          attrs[:liberado_at]  = Time.current if pagamento.has_attribute?(:liberado_at)
          attrs[:payout_error] = nil if pagamento.has_attribute?(:payout_error)

          pagamento.update!(attrs)

          log_info(
            "Pagamento liberado com sucesso",
            pagamento,
            motivo: motivo,
            actor: actor_label(actor)
          )

          sucesso(pagamento)
        else
          registrar_falha_pix!(pagamento, payout.error)
          falha(pagamento, payout.error)
        end
      end
    rescue StandardError => e
      log_error("Erro crítico ao liberar escrow", pagamento, e)
      falha(pagamento, e.message)
    end

    private

    # ======================================================
    # VALIDAÇÕES
    # ======================================================
    def validar_pagamento!(pagamento)
      raise ArgumentError, "Pagamento inválido" unless pagamento.is_a?(Pagamento)
    end

    def contrato_aceito?(pagamento)
      return false unless pagamento.respond_to?(:frete)

      ContratoDigital
        .where(frete_id: pagamento.frete_id)
        .where.not(aceito_em: nil)
        .exists?
    end

    # ======================================================
    # REGISTRO DE FALHAS
    # ======================================================
    def registrar_falha_pix!(pagamento, erro)
      attrs = { payout_status: "falha" }
      attrs[:payout_error] = erro if pagamento.has_attribute?(:payout_error)
      pagamento.update!(attrs)

      log_warn("Falha no PIX", pagamento, erro: erro)
    end

    # ======================================================
    # HELPERS DE RESULTADO
    # ======================================================
    def sucesso(pagamento, metadata = {})
      Result.new(success?: true, pagamento: pagamento, metadata: metadata)
    end

    def falha(pagamento, mensagem)
      Result.new(success?: false, pagamento: pagamento, error: mensagem)
    end

    # ======================================================
    # LOGS (AUDITORIA)
    # ======================================================
    def log_info(msg, pagamento, extra = {})
      @logger.info(log_payload(msg, pagamento, extra))
    end

    def log_warn(msg, pagamento, extra = {})
      @logger.warn(log_payload(msg, pagamento, extra))
    end

    def log_error(msg, pagamento, exception)
      @logger.error(
        log_payload(msg, pagamento, error: exception.message, backtrace: exception.backtrace&.first)
      )
    end

    def log_payload(msg, pagamento, extra = {})
      {
        service: "EscrowService",
        message: msg,
        pagamento_id: pagamento&.id,
        status: pagamento&.status,
        extra: extra
      }.to_json
    end

    # ======================================================
    # ACTOR
    # ======================================================
    def actor_label(actor)
      return "system" if actor.blank?
      return actor.email if actor.respond_to?(:email) && actor.email.present?
      actor.to_s
    end
  end
end
