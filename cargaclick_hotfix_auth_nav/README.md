CargaClick — Hotfix (auth scope + navbar)
========================================

Este pacote NÃO substitui o seu projeto inteiro. Ele traz:
- PATCHES/authenticate_scope_method.rb  (código do método para colar no ApplicationController)
- app/views/shared/_navbar.html.erb      (navbar com botões de Clientes/Fretes/Transportadores + login/logout)

POR QUE O ERRO ACONTECE
-----------------------
Você está chamando `authenticate_cliente!` no ApplicationController, mas o método só existe
se houver um devise scope configurado para Cliente (ex.: `devise_for :clientes`).
Como o scope não existe (ou não está carregado), o Rails lança:
  undefined method `authenticate_cliente!`

CORREÇÃO RÁPIDA (RECOMENDADA)
-----------------------------
1) Abra: app/controllers/application_controller.rb
2) Encontre o método `authenticate_scope!` (no seu log aparece por volta da linha 59).
3) SUBSTITUA o corpo/implementação do método pelo conteúdo do arquivo:
     PATCHES/authenticate_scope_method.rb

Esta versão é "à prova de falhas":
- Se o scope `cliente` não existir, ela não chama `authenticate_cliente!` e não quebra.
- Admin/Transportador continuam autenticando normalmente se existirem.
- Páginas públicas (ex.: simulação) continuam acessíveis sem login.

4) Navbar (botões)
   Copie o arquivo:
     app/views/shared/_navbar.html.erb
   para o seu projeto no MESMO caminho (crie as pastas se necessário).

   Se seu projeto usa outro partial (ex.: app/views/layouts/_navbar.html.erb),
   copie o conteúdo para o seu partial atual.

5) Garanta que seu layout está renderizando a navbar.
   Exemplo no app/views/layouts/application.html.erb:
     <%= render "shared/navbar" %>

6) Reinicie o servidor:
     bin/dev
     # ou
     rails s

SE VOCÊ QUISER LOGIN PARA CLIENTES (OPCIONAL)
---------------------------------------------
A correção acima para de quebrar e libera público. Mas se você QUER `authenticate_cliente!`,
então você precisa ter Devise para Cliente. Exemplo:

  rails g devise Cliente
  rails db:migrate

e em config/routes.rb:
  devise_for :clientes

Depois disso, o método `authenticate_cliente!` passará a existir.

Observação importante
---------------------
Este hotfix tenta ser compatível com diferentes configurações de rotas.
A navbar só mostra links quando o helper de rota existe (respond_to?).

Boa prática
-----------
Em vez de autenticar tudo globalmente no ApplicationController, prefira colocar
`before_action` apenas nos controllers que realmente precisam de login.
