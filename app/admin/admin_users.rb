# app/admin/admin_users.rb
ActiveAdmin.register AdminUser do
  # 🔑 Permissões fortes
  permit_params :email, :password, :password_confirmation

  # === INDEX ==================================================
  index do
    selectable_column
    id_column
    column :email
    column("Último acesso") { |u| u.current_sign_in_at&.strftime("%d/%m/%Y %H:%M") }
    column("Qtd. logins")   { |u| u.sign_in_count }
    column("Criado em")     { |u| u.created_at.strftime("%d/%m/%Y") }
    actions
  end

  # === SHOW ===================================================
  show do
    attributes_table do
      row :id
      row :email
      row("Último acesso")   { resource.current_sign_in_at }
      row("Qtd. de logins")  { resource.sign_in_count }
      row :created_at
      row :updated_at
    end

    panel "Atividades relacionadas" do
      para "Aqui podemos listar estatísticas, ex: quantos clientes, transportadores e fretes estão ativos."
    end
  end

  # === FILTROS ================================================
  filter :email
  filter :current_sign_in_at, label: "Último acesso"
  filter :sign_in_count,      label: "Qtd. de logins"
  filter :created_at

  # === FORM ===================================================
  form do |f|
    f.inputs "Detalhes do Admin" do
      f.input :email
      f.input :password
      f.input :password_confirmation
    end
    f.actions
  end

  # === ACTION ITEMS (Botões extras) ===========================
  action_item :view_site, only: :index do
    link_to "Voltar ao site", root_path, class: "button"
  end

  action_item :chat_admin, only: :show do
    link_to "Ver Chats", admin_chats_path, class: "button" if defined?(Chat)
  end
end

