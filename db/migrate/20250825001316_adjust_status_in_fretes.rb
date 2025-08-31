class AdjustStatusInFretes < ActiveRecord::Migration[7.1]
  def change
    # garante que status é inteiro (enum-friendly) e default = 0 (pendente)
    change_column :fretes, :status, :integer, default: 0, using: "status::integer"
  end
end
