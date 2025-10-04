# ================================================================
# Etapa 1: Build - instala dependências e pré-compila assets
# ================================================================
FROM ruby:3.2.4-slim AS build

ENV LANG=C.UTF-8 \
    RAILS_ENV=production \
    RACK_ENV=production

# Dependências de build
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    libpq-dev \
    tzdata \
    shared-mime-info \
  && rm -rf /var/lib/apt/lists/*

# Node 20 + Yarn via Corepack (sem repositório Yarn legado)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get update -qq && apt-get install -y --no-install-recommends nodejs \
  && corepack enable \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copia Gemfile para cache do bundler
COPY Gemfile Gemfile.lock ./
RUN gem install bundler \
  && bundle config set deployment 'true' \
  && bundle config set without 'development test' \
  && bundle install --jobs 4 --retry 3

# Copia restante do código da aplicação
COPY . .

# Variáveis mínimas para build
ARG RAILS_MASTER_KEY
ENV RAILS_MASTER_KEY=${RAILS_MASTER_KEY}
ENV SECRET_KEY_BASE=dummy_key
# Dummy DATABASE_URL só para evitar erro no build
ENV DATABASE_URL=postgres://postgres:1234@localhost:5432/dummy

# Falha cedo se a master key não chegou ao build
RUN test -n "$RAILS_MASTER_KEY" || (echo "❌ RAILS_MASTER_KEY ausente no build" && exit 1)

# Pré-compilação de assets
RUN bundle exec rake assets:precompile

# ================================================================
# Etapa 2: Runtime - imagem final mais leve
# ================================================================
FROM ruby:3.2.4-slim AS runtime

# Dependências necessárias apenas para runtime
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    libpq5 \
    tzdata \
    dumb-init \
  && rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV=production \
    RACK_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true

WORKDIR /app

# Copia gems já instaladas e app (com assets pré-compilados) da etapa de build
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app

# Usuario não-root
RUN useradd -m -u 10001 appuser && chown -R appuser:appuser /app
USER appuser

EXPOSE 3000

# Comando padrão para iniciar o Puma
ENTRYPOINT ["dumb-init", "--"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
