# frozen_string_literal: true

class AddDeviseToAdminUsers < ActiveRecord::Migration[7.1]
  def up
    # Campos do Devise já existem em admin_users.
    # Nenhuma ação necessária.
  end

  def down
    # Não há reversão, porque não adicionamos nada novo.
  end
end
