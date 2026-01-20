class AddStatusCadastroToClientesETransportadores < ActiveRecord::Migration[7.1]
  def change
    add_column :clientes, :status_cadastro, :integer, default: 1, null: false
    add_column :transportadores, :status_cadastro, :integer, default: 1, null: false
  end
end
