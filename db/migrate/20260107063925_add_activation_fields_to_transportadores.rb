# frozen_string_literal: true

class AddActivationFieldsToTransportadores < ActiveRecord::Migration[7.1]
  def change
    add_column :transportadores, :activated_at, :datetime
    add_column :transportadores, :last_alert_at, :datetime

    add_index :transportadores, :activated_at
    add_index :transportadores, :last_alert_at
  end
end

