ActiveAdmin.register Pagamento do
  permit_params :frete_id, :transportador_id, :valor, :status, :txid

  index do
    selectable_column
    id_column
    column :frete
    column :transportador
    column :valor
    column :status
    column :txid
    column :created_at
    actions
  end

  filter :frete
  filter :transportador
  filter :valor
  filter :status, as: :select, collection: Pagamento.statuses.keys
  filter :created_at
end
