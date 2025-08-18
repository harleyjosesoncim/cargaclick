config/initializers/devise.rb
# frozen_string_literal: true

# Este arquivo configura o Devise.
# Documentação: https://github.com/heartcombo/devise
# Guia Turbo/Hotwire (Devise 4.9+): https://github.com/heartcombo/devise/wiki/How-To:-Upgrade-to-Devise-4.9.0-%5BHotwire-Turbo-integration%5D

Devise.setup do |config|
  # ---------------------------------------------------------------------------
  # E-mail remetente usado pelos mailers do Devise
  # Sugestão: defina via ENV/credentials em produção.
  # Ex.: Rails.application.credentials.dig(:mail, :from) || ENV["MAIL_FROM"]
  # ---------------------------------------------------------------------------
  config.mailer_sender = "no-reply@cargaclick.com.br"

  # ---------------------------------------------------------------------------
  # ORM
  # ---------------------------------------------------------------------------
  require "devise/orm/active_record"

  # ---------------------------------------------------------------------------
  # Integração Hotwire/Turbo (Rails 7+)
  # Mantém HTML e turbo_stream como formatos navegacionais para redirecionamentos.
  # ---------------------------------------------------------------------------
  config.navigational_formats = ["*/*", :html, :turbo_stream]

  # ---------------------------------------------------------------------------
  # Chave secreta (opcional se Rails já fornece secret_key_base)
  # Em geral, deixe comentado; Devise usa o secret_key_base do Rails.
  # ---------------------------------------------------------------------------
  # config.secret_key = ENV["DEVISE_SECRET_KEY"]

  # ---------------------------------------------------------------------------
  # Stretching de senha (BCrypt). Em testes usa valor baixo para performance.
  # ---------------------------------------------------------------------------
  config.stretches = Rails.env.test? ? 1 : 12

  # ---------------------------------------------------------------------------
  # E-mail case-insensitive e white-space trimming
  # ---------------------------------------------------------------------------
  config.case_insensitive_keys = [:email]
  config.strip_whitespace_keys = [:email]

  # ---------------------------------------------------------------------------
  # Skipa session storage para estratégias específicas (mantém :http_auth fora)
  # ---------------------------------------------------------------------------
  config.skip_session_storage = [:http_auth]

  # ---------------------------------------------------------------------------
  # Tempo de expiração do token de reset de senha
  # ---------------------------------------------------------------------------
  config.reset_password_within = 6.hours

  # ---------------------------------------------------------------------------
  # Lembre-me (rememberable)
  # ---------------------------------------------------------------------------
  config.remember_for = 2.weeks

  # ---------------------------------------------------------------------------
  # Timeoutable (expira sessão após inatividade) — habilite se quiser.
  # É necessário incluir :timeoutable no model (ex.: Cliente).
  # ---------------------------------------------------------------------------
  # config.timeout_in = 30.minutes

  # ---------------------------------------------------------------------------
  # Reconﬁrmable (exige reconﬁrmação quando e-mail muda) — habilite se quiser.
  # Lembre de incluir :confirmable no model e rodar migrações.
  # ---------------------------------------------------------------------------
  # config.reconfirmable = true

  # ---------------------------------------------------------------------------
  # Lockable (trava conta após X tentativas) — habilite se quiser.
  # Lembre de incluir :lockable no model e rodar migrações.
  # ---------------------------------------------------------------------------
  # config.lock_strategy = :failed_attempts
  # config.unlock_keys = [:email]
  # config.unlock_strategy = :email
  # config.maximum_attempts = 5
  # config.last_attempt_warning = true

  # ---------------------------------------------------------------------------
  # Parâmetros de password (comprimento mínimo)
  # ---------------------------------------------------------------------------
  config.password_length = 8..128

  # ---------------------------------------------------------------------------
  # E-mail e senha para autenticação
  # ---------------------------------------------------------------------------
  config.reset_password_keys = [:email]
  config.confirmation_keys = [:email]
  config.authentication_keys = [:email]

  # ---------------------------------------------------------------------------
  # Peppers/Stretch adicionais — defina via ENV/credentials se usar.
  # ---------------------------------------------------------------------------
  # config.pepper = Rails.application.credentials.dig(:devise, :pepper)

  # ---------------------------------------------------------------------------
  # OmniAuth — descomente e configure provedores, se necessário
  # ---------------------------------------------------------------------------
  # config.omniauth :github, ENV["GITHUB_KEY"], ENV["GITHUB_SECRET"], scope: "user,public_repo"

  # ---------------------------------------------------------------------------
  # Mailer/Parent Controllers (se precisar usar ApplicationMailer/Controller custom)
  # ---------------------------------------------------------------------------
  # config.parent_controller = "ApplicationController"
  # config.parent_mailer = "ApplicationMailer"

  # ---------------------------------------------------------------------------
  # Warden hooks/estratégias customizadas (avançado)
  # ---------------------------------------------------------------------------
  # config.warden do |manager|
  #   manager.failure_app = CustomFailureApp
  # end

  # ---------------------------------------------------------------------------
  # Scopes e sign-out
  # ---------------------------------------------------------------------------
  # Por padrão, sign_out scope usa DELETE. Se preferir GET (não recomendado):
  # config.sign_out_via = :get
  config.sign_out_via = :delete
end