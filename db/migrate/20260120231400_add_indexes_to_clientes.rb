class AddIndexesToClientes < ActiveRecord::Migration[7.1]
  def change
    # Evita erro de duplicação caso o índice já exista
    add_index :clientes, :email, unique: true unless index_exists?(:clientes, :email, unique: true)
    add_index :clientes, :reset_password_token, unique: true unless index_exists?(:clientes, :reset_password_token, unique: true)
    add_index :clientes, :status_cadastro unless index_exists?(:clientes, :status_cadastro)
    add_index :clientes, :tipo unless index_exists?(:clientes, :tipo)
  end
end
