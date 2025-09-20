# frozen_string_literal: true

# Use o Devise para configurar as opções de autenticação, como o gerenciamento de
# sessões, senhas, e-mails de confirmação e redefinição de senha.
Devise.setup do |config|
  # É uma boa prática usar uma variável de ambiente ou o Rails credentials para
  # definir o remetente, assim você não expõe o e-mail no código.
  config.mailer_sender = ENV.fetch("DEVISE_MAILER_SENDER", "no-reply@cargaclick.com.br")

  # Define qual ORM (Object-Relational Mapper) o Devise deve usar.
  # No seu caso, o ActiveRecord. Esta linha geralmente não é necessária em
  # novas versões do Rails, mas não há problema em mantê-la.
  require "devise/orm/active_record"

  # Define os formatos que o Devise responderá. Adicionar `turbo_stream` é
  # importante para o uso com o Hotwire/Turbo.
  config.navigational_formats = ["*/*", :html, :turbo_stream]

  # O `stretches` controla o número de iterações do algoritmo de hashing da senha.
  # Um valor maior torna o ataque de força bruta mais lento. Use um valor maior
  # para produção e um menor para testes para acelerar o processo. O valor 12
  # já é uma boa prática.
  config.stretches = Rails.env.test? ? 1 : 12

  # Define o comprimento mínimo e máximo da senha. Mantenha um valor seguro.
  config.password_length = 8..128

  # Define a chave de autenticação (geralmente e-mail ou nome de usuário).
  config.authentication_keys = [:email]

  # Define as chaves para redefinição de senha e confirmação de conta.
  config.reset_password_keys = [:email]
  config.confirmation_keys = [:email]

  # Força as chaves de autenticação a serem tratadas como case-insensitive.
  # Por exemplo, "usuario@exemplo.com" será o mesmo que "USUARIO@EXEMPLO.COM".
  config.case_insensitive_keys = [:email]

  # Remove espaços em branco do início e do fim das chaves de autenticação.
  config.strip_whitespace_keys = [:email]

  # Evita que a sessão seja armazenada para requisições de autenticação HTTP.
  config.skip_session_storage = [:http_auth]

  # Define por quanto tempo o cookie "lembrar de mim" deve durar. 2 semanas é um
  # bom período.
  config.remember_for = 2.weeks

  # Define o método HTTP para a ação de "sign out". O método `delete` é mais
  # seguro e uma boa prática RESTful.
  config.sign_out_via = :delete

  # Define o tempo de validade do token de redefinição de senha. 6 horas é um
  # bom equilíbrio entre segurança e usabilidade.
  config.reset_password_within = 6.hours

  # Opcional: Configura o Devise para redirecionar para uma rota após o login.
  # Você pode usar um helper de rota aqui.
  # config.sign_in_after_reset_password = true
  # config.sign_out_all_scopes_on_sign_out = false

  # Opcional: Se você estiver usando o OmniAuth (para login com Google, Facebook, etc.)
  # config.omniauth :github, "APP_ID", "APP_SECRET"
end