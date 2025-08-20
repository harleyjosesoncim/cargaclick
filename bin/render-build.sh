#!/usr/bin/env bash
set -o errexit

bundle install
bundle exec rails assets:precompile
bundle exec rails assets:clean

# Caso seu plano seja Free, rode migrações aqui:
# bundle exec rails db:migrate
# Caso seu plano seja Paid, rode migrações aqui: