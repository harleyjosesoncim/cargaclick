require 'active_support'
require 'active_support/core_ext'
require 'active_support/encrypted_file'

root = File.expand_path('.', __dir__)
key_path = "#{root}/config/master.key"
credentials_path = "#{root}/config/credentials/development.yml.enc"
plain_credentials_path = "#{root}/config/credentials/development.yml"

key = File.read(key_path).strip

encryptor = ActiveSupport::EncryptedFile.new(
  content_path: credentials_path,
  key_path: key_path,
  env_key: 'RAILS_MASTER_KEY',
  raise_if_missing_key: true
)

plain = File.read(plain_credentials_path)

encryptor.write(plain)

puts "Arquivo development.yml.enc gerado com sucesso!"
