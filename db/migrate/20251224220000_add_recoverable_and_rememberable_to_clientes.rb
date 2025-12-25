# frozen_string_literal: true
class AddRecoverableAndRememberableToClientes < ActiveRecord::Migration[7.1]
  def change
    change_table :clientes, bulk: true do |t|
      # Recoverable
      t.string   :reset_password_token unless column_exists?(:clientes, :reset_password_token)
      t.datetime :reset_password_sent_at unless column_exists?(:clientes, :reset_password_sent_at)

      # Rememberable
      t.datetime :remember_created_at unless column_exists?(:clientes, :remember_created_at)
    end

    add_index :clientes, :reset_password_token, unique: true unless index_exists?(:clientes, :reset_password_token)
    add_index :clientes, :email, unique: true unless index_exists?(:clientes, :email)
  end
end
