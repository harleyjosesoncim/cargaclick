# frozen_string_literal: true

class AddEscrowFieldsToPagamentos < ActiveRecord::Migration[7.1]
  def change
    add_column :pagamentos, :escrow_at, :datetime unless column_exists?(:pagamentos, :escrow_at)
    add_column :pagamentos, :liberado_at, :datetime unless column_exists?(:pagamentos, :liberado_at)

    add_column :pagamentos, :payout_txid, :string unless column_exists?(:pagamentos, :payout_txid)
    add_column :pagamentos, :payout_status, :string, default: "pendente" unless column_exists?(:pagamentos, :payout_status)
    add_column :pagamentos, :payout_error, :text unless column_exists?(:pagamentos, :payout_error)

    # Idempotência dos callbacks do gateway: evita múltiplos registros com o mesmo payment_id
    add_index :pagamentos, :txid, unique: true unless index_exists?(:pagamentos, :txid, unique: true)

    add_index :pagamentos, :payout_txid unless index_exists?(:pagamentos, :payout_txid)
  end
end
