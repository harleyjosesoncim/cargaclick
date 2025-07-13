class AddObservacoesEAlbaNumeroToClientes < ActiveRecord::Migration[7.1]
  def change
    add_column :clientes, :observacoes, :string, limit: 50
    add_column :clientes, :alba_numero, :integer
  end
end
