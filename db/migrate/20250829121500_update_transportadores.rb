class UpdateTransportadores < ActiveRecord::Migration[7.1]
  def change
    change_column :transportadores, :cpf, :string, limit: 11 if column_exists?(:transportadores, :cpf)
    remove_index :transportadores, :email if index_exists?(:transportadores, :email)
    add_index :transportadores, :email, unique: true, where: "email IS NOT NULL" unless index_exists?(:transportadores, :email)
    change_column :transportadores, :carga_maxima, :decimal, precision: 10, scale: 2 if column_exists?(:transportadores, :carga_maxima)
  end
end
