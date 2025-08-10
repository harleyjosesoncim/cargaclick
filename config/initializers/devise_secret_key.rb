# Evita o uso de Rails.application.secrets (deprecado)
Devise.secret_key =
  ENV["DEVISE_SECRET_KEY"] ||
  ENV["SECRET_KEY_BASE"] ||
  (Rails.application.credentials.respond_to?(:secret_key_base) ? Rails.application.credentials.secret_key_base : nil)
