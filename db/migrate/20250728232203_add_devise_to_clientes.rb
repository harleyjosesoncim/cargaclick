class AddDeviseToClientes < ActiveRecord::Migration[7.1]
  def change
    change_table :clientes, bulk: true do |t|
      # ⚠️ NÃO adicione :email novamente — já existe
      # Apenas adiciona os campos novos necessários

      ## Campo obrigatório para login com Devise
      t.string :encrypted_password, null: false, default: ""

      ## Recuperação de senha
      t.string   :reset_password_token
      t.datetime :reset_password_sent_at

      ## Lembrete de sessão
      t.datetime :remember_created_at

      ## (Opcional) Rastrear login
      # t.integer  :sign_in_count, default: 0, null: false
      # t.datetime :current_sign_in_at
      # t.datetime :last_sign_in_at
      # t.string   :current_sign_in_ip
      # t.string   :last_sign_in_ip

      ## (Opcional) Confirmação de conta
      # t.string   :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string   :unconfirmed_email

      ## (Opcional) Lockable
      # t.integer  :failed_attempts, default: 0, null: false
      # t.string   :unlock_token
      # t.datetime :locked_at
    end

    # Indexes seguros
    add_index :clientes, :email, unique: true unless index_exists?(:clientes, :email)
    add_index :clientes, :reset_password_token, unique: true
  end
end
