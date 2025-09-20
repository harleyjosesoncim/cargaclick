# Etapa 1: Build - Onde as dependências são instaladas e os assets pré-compilados
FROM ruby:3.2.4 AS build

# Instalação de dependências de sistema para o build
RUN apt-get update -qq && apt-get install -y nodejs yarn build-essential libpq-dev

WORKDIR /app

# Copia Gemfile para aproveitar o cache do Docker
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --without development test

# Copia o restante do código da aplicação
COPY . .

# Pré-compilação de assets
# O SECRET_KEY_BASE é necessário para o Rails rodar a pré-compilação
ENV RAILS_ENV=production
ENV SECRET_KEY_BASE=dummy_key
RUN bundle exec rails assets:precompile

# ---
# Etapa 2: Runtime - Uma imagem final mais leve para rodar a aplicação
FROM ruby:3.2.4

# Instalação de dependências de sistema necessárias APENAS para o runtime
RUN apt-get update -qq && apt-get install -y libpq-dev

WORKDIR /app

# Copia o diretório de instalação do Bundler completo da etapa de build
# Esta é a linha mais importante para resolver o problema!
COPY --from=build /usr/local/bundle /usr/local/bundle

# Copia todos os arquivos da aplicação da etapa de build, incluindo os assets pré-compilados
COPY --from=build /app /app

# Comando para iniciar a aplicação com o Puma
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]

