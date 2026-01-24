# frozen_string_literal: true

module Efi
  class PixPayoutService
    def self.call(pagamento)
      # =========================
      # Guardas defensivas
      # =========================
      raise "Pagamento não encontrado" if pagamento.nil?
      raise "Pagamento inválido" unless pagamento.status == "pendente"
      raise "Transportador inválido" unless pagamento.transportador.pode_receber_pagamento?

      # Marca como processando para evitar dupla execução
      pagamento.update!(status: "processando")

      # =========================
      # Chamada à EFI (stub controlado)
      # =========================
      # Aqui entra a SDK/API real da EFI.
      response = {
        status: "success",
        txid: SecureRandom.uuid
      }

      # =========================
      # Tratamento da resposta
      # =========================
      if response[:status] == "success"
        pagamento.update!(
          status: "pago",
          pago_em: Time.current,
          txid: response[:txid],
          erro_mensagem: nil
        )

        # Atualiza o frete somente após pagamento confirmado
        pagamento.frete.update!(status: "pago")
      else
        pagamento.update!(
          status: "erro",
          erro_mensagem: "Falha ao processar PIX na EFI"
        )
      end

      pagamento
    rescue => e
      # Fallback de segurança (log + marca erro se ainda não pago)
      pagamento.update!(
        status: "erro",
        erro_mensagem: e.message
      ) if pagamento&.status != "pago"

      raise e
    end
  end
end
