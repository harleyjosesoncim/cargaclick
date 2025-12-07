# app/services/taxas/calculadora.rb
# frozen_string_literal: true

module Taxas
  class Calculadora
    # Regra de negócio resumida:
    # - Taxa padrão: 8%
    # - Transportador com bônus de fidelidade → 5%
    TAXA_PADRAO     = BigDecimal("0.08")
    TAXA_FIDELIDADE = BigDecimal("0.05")

    class << self
      # Retorna a taxa (0.08 ou 0.05) de acordo com o transportador
      def taxa_para(transportador)
        return TAXA_PADRAO if transportador.blank?

        if transportador.respond_to?(:fidelidade_bonus?) && transportador.fidelidade_bonus?
          TAXA_FIDELIDADE
        else
          TAXA_PADRAO
        end
      end

      # Calcula o valor da comissão em dinheiro
      def comissao(valor_total, transportador)
        base = valor_total.to_d
        taxa = taxa_para(transportador)
        (base * taxa).round(2)
      end
    end
  end
end
