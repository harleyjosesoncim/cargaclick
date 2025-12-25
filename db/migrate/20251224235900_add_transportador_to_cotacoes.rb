# frozen_string_literal: true

class AddTransportadorToCotacoes < ActiveRecord::Migration[7.1]
  def change
    return if column_exists?(:cotacoes, :transportador_id)

    add_reference :cotacoes, :transportador, foreign_key: true, index: true
  end
end
