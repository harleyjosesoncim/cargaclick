class AddFreteIdToPagamentos < ActiveRecord::Migration[6.1]
  def change
    # frete_id já existe na tabela pagamentos → não fazer nada
    # add_reference :pagamentos, :frete, null: false, foreign_key: true
  end
end
