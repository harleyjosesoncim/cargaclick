ActiveAdmin.register Frete do
  permit_params :cliente_id, :origem, :destino, :cep_origem, :cep_destino,
                :status, :valor_estimado, :valor_final, :peso, :volume, :contatos_liberados

  index do
    selectable_column
    id_column
    column :cliente
    column :origem
    column :destino
    column :status
    column :valor_estimado
    column :valor_final
    column :peso
    column :volume
    column :contatos_liberados
    column :created_at
    actions
  end

  filter :cliente
  filter :status
  filter :origem
  filter :destino
  filter :valor_final
  filter :created_at
end
