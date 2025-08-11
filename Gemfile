source "https://rubygems.org"
git_source(:github) { |repo| "https://github.com/#{repo}.git" }

ruby "3.2.4" # Verifique se esta é a versão do seu Ruby

# Bundle edge Rails instead: gem "rails", github: "rails/rails", branch: "main"
gem "rails", "~> 7.1.3" # Ou a versão exata do Rails que você está usando
gem 'pg'

gem 'puma', '~> 6.0'
gem 'bcrypt', '~> 3.1.7'


# NOVAS GEMS PARA O PIPELINE DE ASSETS (ESBuild e TailwindCSS)
gem "jsbundling-rails"
gem "cssbundling-rails"
# As linhas de 'REMOVE A LINHA ABAIXO:' e as gems comentadas (sass-rails, tailwindcss-rails) foram removidas para limpeza.
gem 'turbolinks', '~> 5' # Mantenha se você ainda usa Turbolinks

# Gems de Autenticação e Utilidades
gem 'devise'
gem 'httparty'
gem 'bootsnap', '>= 1.16', require: false
gem "sprockets-rails"
gem 'ruby-openai'
gem 'dotenv-rails', groups: [:development, :test]


# Gems de Pagamento (descomente quando for integrar, se for o caso)
# gem 'mercadopago-sdk', '~> 2.4'
# gem 'efi-client', '~> 1.0'

# Gems de desenvolvimento e teste (não instaladas em produção)
group :development, :test do
  # Adicione suas gems de dev/test aqui
  # gem "debug", platforms: %i[ mri mingw x64_mingw ]
  gem 'pry'
  gem 'pry-nav'
end

# Para rodar testes de sistema com Capybara/Selenium
# group :test do
#   gem "capybara"
#   gem "selenium-webdriver"
# end
# ----FIM---- ATÉ AQUI

gem "rails_admin", "~> 3.3"
gem "sassc-rails"

# Error monitoring
gem "sentry-ruby"
gem "sentry-rails"
