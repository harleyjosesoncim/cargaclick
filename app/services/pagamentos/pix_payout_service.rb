# frozen_string_literal: true

# Serviço responsável por executar o repasse (Pix) ao transportador.
#
# V7: estrutura pronta para integração real (gateway/banco), porém por padrão
# opera em modo "simulado" (ledger) caso não haja credenciais específicas.
# O objetivo é garantir o fluxo de negócio: escrow -> liberado.

module Pagamentos
  class PixPayoutService
    Result = Struct.new(:success?, :payout_txid, :error, keyword_init: true)

    def initialize(simulado: nil)
      # Se não explicitado, assume simulado quando não houver provider configurado
      @simulado = simulado.nil? ? ENV["PAYOUT_PROVIDER"].blank? : simulado
      @provider = ENV["PAYOUT_PROVIDER"].to_s.strip.downcase.presence
    end

    # Executa o repasse do valor_liquido para a chave Pix do transportador
    def transferir!(pagamento)
      validar!(pagamento)

      if @simulado
        txid = "pix_sim_#{SecureRandom.hex(10)}"
        Rails.logger.info("[PAYOUT] (simulado) repasse txid=#{txid} pagamento_id=#{pagamento.id} " \
                         "valor=#{pagamento.valor_liquido} chave_pix=#{pagamento.transportador&.chave_pix}")
        return Result.new(success?: true, payout_txid: txid)
      end

      case @provider
      when "mercadopago", "mp"
        # Placeholder para integração real.
        # Recomenda-se implementar via API de pagamentos/transferências do provedor,
        # usando conta do transportador (se aplicável) ou Pix direto.
        raise NotImplementedError, "PAYOUT_PROVIDER=mercadopago ainda não implementado (V7)"
      when "efi", "efibank"
        raise NotImplementedError, "PAYOUT_PROVIDER=efi ainda não implementado (V7)"
      else
        raise ArgumentError, "PAYOUT_PROVIDER inválido: #{@provider.inspect}"
      end
    rescue StandardError => e
      Rails.logger.error("[PAYOUT] falha no repasse pagamento_id=#{pagamento&.id}: #{e.message}")
      Result.new(success?: false, payout_txid: nil, error: e.message)
    end

    private

    def validar!(pagamento)
      raise ArgumentError, "pagamento inválido" unless pagamento.is_a?(Pagamento)
      raise ArgumentError, "pagamento sem transportador" unless pagamento.transportador.present?
      raise ArgumentError, "valor_liquido inválido" unless pagamento.valor_liquido.to_d.positive?

      transportador = pagamento.transportador
      unless transportador.respond_to?(:pode_receber_pagamento?) && transportador.pode_receber_pagamento?
        raise ArgumentError, "transportador não apto a receber pagamento (status/chave_pix)"
      end
    end
  end
end
