# ================================================================
# Etapa 1: BUILD — instala dependências e pré-compila assets
# ================================================================
FROM ruby:3.2.4-slim AS build

ENV LANG=C.UTF-8 \
    RAILS_ENV=production \
    RACK_ENV=production \
    BUNDLE_WITHOUT="development:test"

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
# use a mesma versão do bundler da sua imagem/lock (se precisar fixe com: gem install bundler -v X.Y.Z)
RUN bundle config set deployment 'true' \
  && bundle config set without 'development test' \
  && bundle install --jobs 4 --retry 3

# Node deps (se não houver package.json, ignora)
COPY package.json yarn.lock* ./
RUN [ -f package.json ] && yarn install --frozen-lockfile || true

# Código da aplicação
COPY . .

# Variáveis mínimas p/ build de assets
# - SECRET_KEY_BASE dummy permite inicialização em produção durante o build
# - DATABASE_URL dummy evita erros em inicializadores que inspectam ActiveRecord
ENV SECRET_KEY_BASE=dummy_key \
    DATABASE_URL=postgres://postgres:1234@localhost:5432/dummy

# Pré-compilação de assets (não exige master key)
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
    BUNDLE_WITHOUT="development:test"

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

# Healthcheck (opcional, o Render usa health path se você configurar)
# HEALTHCHECK --interval=30s --timeout=5s --start-period=20s --retries=3 \
#   CMD wget -qO- http://127.0.0.1:${PORT:-3000}/up || exit 1

# Entrypoint + Puma
ENTRYPOINT ["dumb-init", "--"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
