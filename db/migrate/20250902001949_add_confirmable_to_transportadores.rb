# frozen_string_literal: true
class AddConfirmableToTransportadores < ActiveRecord::Migration[7.1]
  def change
    change_table :transportadores, bulk: true do |t|
      t.string   :confirmation_token unless column_exists?(:transportadores, :confirmation_token)
      t.datetime :confirmed_at unless column_exists?(:transportadores, :confirmed_at)
      t.datetime :confirmation_sent_at unless column_exists?(:transportadores, :confirmation_sent_at)
      t.string   :unconfirmed_email unless column_exists?(:transportadores, :unconfirmed_email)
    end

    add_index :transportadores, :confirmation_token, unique: true unless index_exists?(:transportadores, :confirmation_token)
  end
end
