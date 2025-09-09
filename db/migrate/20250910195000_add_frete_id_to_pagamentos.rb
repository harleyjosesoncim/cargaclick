class AddFreteIdToPagamentos < ActiveRecord::Migration[6.1]
  def change
    add_reference :pagamentos, :frete, null: false, foreign_key: true
  end
end
