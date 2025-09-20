# Inicia o servidor web com Puma
web: bundle exec puma -C config/puma.rb

# Executa migrations + seeds automaticamente no deploy
release: bundle exec rails db:migrate db:seed RAILS_ENV=production
