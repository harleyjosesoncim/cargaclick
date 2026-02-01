class AddTipoPessoaToTransportadores < ActiveRecord::Migration[7.1]
  def change
    add_column :transportadores, :tipo_pessoa, :integer, default: 0, null: false
  end
end
