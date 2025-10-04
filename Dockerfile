# ================================================================
# Etapa 1: BUILD — instala dependências e pré-compila assets
# ================================================================
FROM ruby:3.2.4-slim AS build

ENV LANG=C.UTF-8 \
    RAILS_ENV=production \
    RACK_ENV=production \
    BUNDLE_WITHOUT="development:test" \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_BIN=/usr/local/bundle/bin

# Dependências de build
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    libpq-dev \
    tzdata \
    shared-mime-info \
  && rm -rf /var/lib/apt/lists/*

# Node 20 + Corepack (Yarn moderno)
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get update -qq && apt-get install -y --no-install-recommends nodejs \
  && corepack enable \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Gems (cache)
COPY Gemfile Gemfile.lock ./
RUN bundle config set deployment 'true' \
  && bundle config set without 'development test' \
  && bundle config set path "$BUNDLE_PATH" \
  && bundle install --jobs 4 --retry 3

# Node deps (se não houver package.json, ignora)
COPY package.json yarn.lock* ./
RUN [ -f package.json ] && yarn install --frozen-lockfile || true

# Código da aplicação
COPY . .

# Variáveis mínimas p/ build de assets (NÃO usar master key no build)
# - SECRET_KEY_BASE dummy permite inicialização em produção durante o build
# - DATABASE_URL dummy evita erros em inicializadores que inspecionam ActiveRecord
# - SKIP_MASTER_KEY=1 alinha com production.rb para dispensar master key no build
# - ASSETS_PRECOMPILE=1 permite "pular" inicializadores que usam credentials
ENV SECRET_KEY_BASE=dummy_key \
    DATABASE_URL=postgres://postgres:1234@localhost:5432/dummy \
    SKIP_MASTER_KEY=1 \
    ASSETS_PRECOMPILE=1

# (opcional) debug — confirme que as ENVs estão setadas
# RUN echo "SKIP_MASTER_KEY=$SKIP_MASTER_KEY  ASSETS_PRECOMPILE=$ASSETS_PRECOMPILE  RAILS_ENV=$RAILS_ENV"

# Pré-compilação de assets
RUN bundle exec rake assets:precompile

# Ajusta permissões para o runtime não-root já no artefato
RUN mkdir -p tmp/pids log && chmod -R 775 tmp log

# ================================================================
# Etapa 2: RUNTIME — imagem final, leve e segura
# ================================================================
FROM ruby:3.2.4-slim AS runtime

# Dependências necessárias em runtime
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    libpq5 \
    tzdata \
    dumb-init \
  && rm -rf /var/lib/apt/lists/*

ENV RAILS_ENV=production \
    RACK_ENV=production \
    RAILS_LOG_TO_STDOUT=1 \
    RAILS_SERVE_STATIC_FILES=1 \
    BUNDLE_WITHOUT="development:test" \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_BIN=/usr/local/bundle/bin

WORKDIR /app

# Copia gems e app (com assets compilados)
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app

# Usuário não-root e permissões de escrita
RUN useradd -m -u 10001 appuser \
  && chown -R appuser:appuser /app
USER appuser

# Garantir diretórios de pid/log em runtime
RUN mkdir -p tmp/pids log

EXPOSE 3000

# Entrypoint + Puma
ENTRYPOINT ["dumb-init", "--"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
