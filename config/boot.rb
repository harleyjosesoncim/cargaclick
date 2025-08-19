# config/boot.rb

# Garante que o Bundler use o Gemfile do app
ENV["BUNDLE_GEMFILE"] ||= File.expand_path("../Gemfile", __dir__)

require "bundler/setup"  # Carrega as gems listadas no Gemfile

# Acelera o boot (cache de require). Se a gem não estiver presente, ignore.
begin
  require "bootsnap/setup"
rescue LoadError
  # ok sem bootsnap
end

# Carrega variáveis do .env **apenas** em desenvolvimento e teste
env = ENV["RAILS_ENV"] || ENV["RACK_ENV"] || "development"
if %w[development test].include?(env)
  begin
    require "dotenv/load"
  rescue LoadError
    # dotenv-rails só está em dev/test; em prod não deve carregar
  end
end
