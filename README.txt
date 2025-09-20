# Módulo Contatos - CargaClick

## Instalação
1. Copie as pastas `app/` e `db/` deste pacote para dentro do seu projeto Rails.
2. No arquivo `config/routes.rb`, adicione:
   ```ruby
   resources :contatos, only: [:new, :create]
   ```
3. Rode a migration:
   ```bash
   rails db:migrate
   ```
4. Acesse em: `http://localhost:3000/contatos/new`

Pronto! O formulário 'Fale Conosco' estará funcionando e salvando mensagens no banco de dados.
