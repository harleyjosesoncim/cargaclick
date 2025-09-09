ActiveAdmin.register Message do
  permit_params :frete_id, :sender_type, :sender_id, :content, :status

  index do
    selectable_column
    id_column
    column :frete
    column :sender_type
    column :sender_id
    column :content
    column :status
    column :created_at
    actions
  end

  filter :frete
  filter :sender_type
  filter :sender_id
  filter :status
  filter :created_at
end
