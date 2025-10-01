# ================================================================
# Etapa 1: Build - instala dependências e pré-compila assets
# ================================================================
FROM ruby:3.2.4 AS build

# Dependências necessárias no build
RUN apt-get update -qq && apt-get install -y nodejs yarn build-essential libpq-dev

WORKDIR /app

# Copia Gemfile para aproveitar cache
COPY Gemfile Gemfile.lock ./
RUN gem install bundler && bundle install --without development test

# Copia restante do código da aplicação
COPY . .

# Variáveis mínimas para build
ENV RAILS_ENV=production
ENV SECRET_KEY_BASE=dummy_key
# Dummy DATABASE_URL só para evitar erro no build
ENV DATABASE_URL=postgres://postgres:1234@localhost:5432/dummy

# Pré-compilação de assets
RUN bundle exec rails assets:precompile

# ================================================================
# Etapa 2: Runtime - imagem final mais leve
# ================================================================
FROM ruby:3.2.4

# Dependências necessárias apenas para runtime
RUN apt-get update -qq && apt-get install -y libpq-dev

WORKDIR /app

# Copia gems já instaladas da etapa de build
COPY --from=build /usr/local/bundle /usr/local/bundle

# Copia código da aplicação (já com assets pré-compilados)
COPY --from=build /app /app

# Comando padrão para iniciar o Puma
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
