Devise.setup do |config|
  # Se você quiser chave dedicada ao Devise, descomente a linha abaixo.
  # Caso contrário, o Devise usará Rails.application.secret_key_base automaticamente.
  #
  # prioridade: DEVISE_SECRET_KEY -> credentials.devise_secret_key -> secret_key_base
  key =
    ENV["DEVISE_SECRET_KEY"].presence ||
    Rails.application.credentials.devise_secret_key ||
    Rails.application.secret_key_base

  config.secret_key = key
end
