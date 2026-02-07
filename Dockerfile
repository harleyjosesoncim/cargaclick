# ================================================================
# STAGE 1 — BUILD (gems + node + assets)
# ================================================================
FROM ruby:3.2.4-slim AS build

# ---------------- ENV padrão ----------------
ENV LANG=C.UTF-8 \
    RAILS_ENV=production \
    RACK_ENV=production \
    BUNDLE_WITHOUT="development:test" \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_BIN=/usr/local/bundle/bin \
    NODE_ENV=production

# ---------------- Pacotes de build ----------------
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    git \
    curl \
    libpq-dev \
    tzdata \
    shared-mime-info \
  && rm -rf /var/lib/apt/lists/*

# ---------------- Node 20 + Yarn ----------------
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
  && apt-get update -qq \
  && apt-get install -y --no-install-recommends nodejs \
  && corepack enable \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# ---------------- Gems (cacheável) ----------------
COPY Gemfile Gemfile.lock ./
RUN bundle config set deployment 'true' \
 && bundle config set without 'development test' \
 && bundle install --jobs 4 --retry 3

# ---------------- Node deps (opcional) ----------------
COPY package.json yarn.lock* ./
RUN [ -f package.json ] && yarn install --frozen-lockfile || true

# ---------------- App ----------------
COPY . .

# ---------------- ENVs SOMENTE PARA BUILD ----------------
# ⚠️ NÃO usar master.key aqui
# Isso evita o erro de credentials durante assets:precompile
ENV SECRET_KEY_BASE=dummy \
    DATABASE_URL=postgres://postgres:postgres@localhost:5432/dummy \
    SKIP_MASTER_KEY=1 \
    RAILS_LOG_TO_STDOUT=1 \
    RAILS_SERVE_STATIC_FILES=1

# ---------------- Assets ----------------
RUN bundle exec rake assets:precompile

# Garantir pastas usadas em runtime
RUN mkdir -p tmp/pids log \
 && chmod -R 775 tmp log

# ================================================================
# STAGE 2 — RUNTIME (imagem final)
# ================================================================
FROM ruby:3.2.4-slim AS runtime

# ---------------- Pacotes mínimos ----------------
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    libpq5 \
    tzdata \
    dumb-init \
  && rm -rf /var/lib/apt/lists/*

ENV LANG=C.UTF-8 \
    RAILS_ENV=production \
    RACK_ENV=production \
    RAILS_LOG_TO_STDOUT=1 \
    RAILS_SERVE_STATIC_FILES=1 \
    BUNDLE_WITHOUT="development:test" \
    BUNDLE_PATH=/usr/local/bundle \
    BUNDLE_BIN=/usr/local/bundle/bin

WORKDIR /app

# ---------------- Copiar build ----------------
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app

# ---------------- Usuário seguro ----------------
RUN useradd -m -u 10001 appuser \
 && chown -R appuser:appuser /app

USER appuser

RUN mkdir -p tmp/pids log

EXPOSE 10000

# ---------------- Start ----------------
ENTRYPOINT ["dumb-init", "--"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
