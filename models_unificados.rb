class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class
end
# app/models/cliente.rb
class Cliente < ApplicationRecord
  # Validações para garantir que nome e email não estejam vazios
  validates :nome, presence: true
  validates :email, presence: true, uniqueness: true # Garante que o email é único
  validates_format_of :email, with: URI::MailTo::EMAIL_REGEXP # Valida o formato do email
  class Cliente < ApplicationRecord
  validates :observacoes, length: { maximum: 50 }
end

endclass Configuracao < ApplicationRecord
  # Exemplo de configuração global do sistema
  # Campo: comissao_padrao:float, comissao_assinante:float
end
class Cotacao < ApplicationRecord
end
class Frete < ApplicationRecord
  belongs_to :cliente

  def valor_comissao
    config = Configuracao.first
    percentual = cliente.assinante? ? config.comissao_assinante : config.comissao_padrao
    valor_estimado * (percentual / 100.0)
  end
end
class Transportador < ApplicationRecord
  self.table_name = "transportadores"
  has_many :fretes
end
