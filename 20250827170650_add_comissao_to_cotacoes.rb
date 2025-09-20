class AddComissaoToCotacoes < ActiveRecord::Migration[7.1]
  def change
    add_column :cotacoes, :comissao, :decimal, precision: 10, scale: 2, default: 0, null: false
  end
end
# == Schema Information
# Table name: cotacoes
#  id              :bigint           not null, primary key
#  comissao        :decimal(10, 2)      default(0.0), not null
#  status         :string           default("pendente"), not null
#  valor           :decimal(10, 2)
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  carga_id       :bigint           not null
#  transportadora_id :bigint           not null
# Indexes
#  index_cotacoes_on_carga_id         (carga_id)
#  index_cotacoes_on_transportadora_id  (transportadora_id) 