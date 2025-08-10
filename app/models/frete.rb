class Frete < ApplicationRecord
  belongs_to :cliente
  enum status: { pendente: 0, em_andamento: 1, entregue: 2 }
    def valor_comissao
    config = Configuracao.first
    percentual = cliente.assinante? ? config.comissao_assinante : config.comissao_padrao
    valor_estimado * (percentual / 100.0)
  end
end
