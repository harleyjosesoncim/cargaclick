# frozen_string_literal: true

class ComissaoCalculator
  # Percentual exibido na interface (marketing / UX)
  def self.exibida
    6
  end

  # Percentual real padrão (protege margem)
  def self.comissao_operacional
    7
  end

  # Percentual reduzido por fidelidade
  def self.fidelidade_percentual
    5
  end

  # FONTE ÚNICA DE DECISÃO
  def self.percentual_para(transportador)
    if transportador&.respond_to?(:fidelidade?) && transportador.fidelidade?
      fidelidade_percentual
    else
      comissao_operacional
    end
  end
end
