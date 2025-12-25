# app/services/taxas/calculadora.rb
# frozen_string_literal: true

module Taxas
  class Calculadora
    # Taxa do sistema (mais atrativa que grandes players):
    # - Padrão: 6%
    # - Bônus fidelidade: 4%
    TAXA_PADRAO     = BigDecimal("0.06")
    TAXA_FIDELIDADE = BigDecimal("0.04")

    # Comissão mínima opcional para cobrir custo fixo em fretes muito pequenos
    MIN_COMISSAO = BigDecimal("1.99")

    class << self
      def taxa_para(transportador)
        return TAXA_PADRAO if transportador.blank?

        # Se o model tiver método/flag de bônus, usa; senão, cai no padrão
        if transportador.respond_to?(:fidelidade_bonus?) && transportador.fidelidade_bonus?
          TAXA_FIDELIDADE
        elsif transportador.respond_to?(:fidelidade_pontos) && transportador.fidelidade_pontos.to_i >= 100
          TAXA_FIDELIDADE
        else
          TAXA_PADRAO
        end
      end

      def comissao(valor_total, transportador)
        base = valor_total.to_d
        return 0.to_d if base <= 0

        taxa = taxa_para(transportador)
        calculada = (base * taxa).round(2)

        # Aplica comissão mínima, mas nunca acima de 15% do total (para manter atratividade)
        min_aplicavel = [MIN_COMISSAO, (base * BigDecimal("0.15")).round(2)].min

        com = [calculada, min_aplicavel].max
        [com, base].min
      end
    end
  end
end
