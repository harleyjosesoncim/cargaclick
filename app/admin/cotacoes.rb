ActiveAdmin.register Cotacao do
  permit_params :frete_id, :transportador_id, :valor, :status, :comissao

  index do
    selectable_column
    id_column
    column :frete
    column :transportador
    column :valor
    column :status
    column :comissao
    column :created_at
    actions
  end

  filter :frete
  filter :transportador
  filter :valor
  filter :status
  filter :created_at
end
