OPCIONAL — PADRONIZAÇÃO User + Roles
==================================

Este passo é OPCIONAL. Use apenas se quiser UNIFICAR:
  - Cliente
  - Transportador
  - Admin

em um único model User.

VANTAGENS
---------
- Um único login
- Menos Devise scopes
- Controle por role (enum)

MODELO
------
rails g devise User role:integer nome:string telefone:string cpf:string
rails db:migrate

app/models/user.rb
------------------
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  enum role: { cliente: 0, transportador: 1, admin: 2 }
end

AUTORIZAÇÃO
-----------
before_action :authenticate_user!
before_action -> { redirect_to root_path unless current_user.admin? }

ROTAS
-----
devise_for :users

E você REMOVE:
  devise_for :clientes
  devise_for :transportadores
  devise_for :admins

IMPORTANTE
----------
Faça essa migração apenas quando o sistema estiver estável.
