# syntax = docker/dockerfile:1

# Ajuste automático pela .ruby-version
ARG RUBY_VERSION=3.2.4
FROM ruby:$RUBY_VERSION-slim as base

# Diretório principal do app
WORKDIR /rails

# Ambiente de produção Rails
ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_WITHOUT="development test"

# 🏗️ Stage intermediário para construir app e dependências
FROM base AS build

# Instala dependências para compilar gems e assets
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      build-essential \
      git \
      libpq-dev \
      libvips \
      pkg-config \
      nodejs \
      yarn \
      curl

# Copia Gemfile e instala gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copia código da aplicação
COPY . .

# Precompila bootsnap para inicialização mais rápida
RUN bundle exec bootsnap precompile app/ lib/

# Precompila assets (Webpacker + Tailwind) para produção
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# 🎯 Stage final para a imagem de produção enxuta
FROM base

# Instala pacotes essenciais apenas para runtime
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
      libvips \
      postgresql-client && \
    rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Copia gems e aplicação construídas no stage build
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Cria e ajusta permissões para usuário não-root
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp

USER rails:rails

# Entrypoint prepara DB e roda migrations antes do start
ENTRYPOINT ["/rails/bin/docker-entrypoint"]

# Exposição da porta padrão Rails
EXPOSE 3000

# Comando padrão para iniciar servidor Rails/Puma
CMD ["./bin/rails", "server"]
