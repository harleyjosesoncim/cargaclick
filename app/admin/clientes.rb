ActiveAdmin.register Cliente do
  permit_params :nome, :email, :telefone, :endereco, :cep, :cpf, :cnpj, :cidade, :estado, :ativo

  index do
    selectable_column
    id_column
    column :nome
    column :email
    column :telefone
    column :cpf
    column :cnpj
    column :cidade
    column :estado
    column :ativo
    column :created_at
    actions
  end

  filter :nome
  filter :email
  filter :cpf
  filter :cnpj
  filter :cidade
  filter :estado
  filter :created_at

  form do |f|
    f.inputs do
      f.input :nome
      f.input :email
      f.input :telefone
      f.input :endereco
      f.input :cep
      f.input :cpf
      f.input :cnpj
      f.input :cidade
      f.input :estado
      f.input :ativo
    end
    f.actions
  end
end
