ActiveAdmin.register Transportador do
  permit_params :nome, :cpf, :telefone, :endereco, :cep, :tipo_veiculo, :carga_maxima,
                :valor_km, :largura, :altura, :profundidade, :peso_aproximado,
                :cidade, :email, :chave_pix, :mercado_pago_link, :fidelidade_pontos

  index do
    selectable_column
    id_column
    column :nome
    column :cpf
    column :telefone
    column :tipo_veiculo
    column :carga_maxima
    column :valor_km
    column :cidade
    column :email
    column :chave_pix
    column :fidelidade_pontos
    column :created_at
    actions
  end

  filter :nome
  filter :cpf
  filter :tipo_veiculo
  filter :cidade
  filter :email
  filter :chave_pix
  filter :fidelidade_pontos
  filter :created_at
end
