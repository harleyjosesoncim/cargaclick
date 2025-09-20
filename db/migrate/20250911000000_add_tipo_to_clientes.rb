# frozen_string_literal: true
class AddTipoToClientes < ActiveRecord::Migration[7.1]
  def change
    add_column :clientes, :tipo, :integer, default: 0, null: false
  end
end
