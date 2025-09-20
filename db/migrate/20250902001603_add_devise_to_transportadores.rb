# frozen_string_literal: true
class AddDeviseToTransportadores < ActiveRecord::Migration[7.1]
  def change
    change_table :transportadores, bulk: true do |t|
      ## Database authenticatable
      t.string :email,              null: false, default: "" unless column_exists?(:transportadores, :email)
      t.string :encrypted_password, null: false, default: "" unless column_exists?(:transportadores, :encrypted_password)

      ## Recoverable
      t.string   :reset_password_token unless column_exists?(:transportadores, :reset_password_token)
      t.datetime :reset_password_sent_at unless column_exists?(:transportadores, :reset_password_sent_at)

      ## Rememberable
      t.datetime :remember_created_at unless column_exists?(:transportadores, :remember_created_at)
    end

    add_index :transportadores, :email, unique: true unless index_exists?(:transportadores, :email)
    add_index :transportadores, :reset_password_token, unique: true unless index_exists?(:transportadores, :reset_password_token)
  end
end
