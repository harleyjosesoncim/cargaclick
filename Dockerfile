# ========================================
# Stage 1 — Builder: gems, yarn e precompile
# ========================================
FROM ruby:3.2.4-slim AS builder

# Deps de build (Node+Yarn, compilar gems, libvips p/ ActiveStorage)
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  curl ca-certificates gnupg build-essential git libpq-dev libvips42 && \
  curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
  curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/yarn.gpg && \
  echo "deb [signed-by=/usr/share/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian stable main" > /etc/apt/sources.list.d/yarn.list && \
  apt-get update -qq && apt-get install -y --no-install-recommends nodejs yarn && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Bundler em modo produção
ENV RAILS_ENV=production \
    NODE_ENV=production \
    BUNDLE_WITHOUT=development:test \
    BUNDLE_DEPLOYMENT=true \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3

# Instala gems (cache eficiente)
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Instala pacotes JS se existirem (não falha se não houver)
COPY package.json yarn.lock* ./
RUN yarn install --frozen-lockfile || true

# Copia a app e pré-compila assets (SECRET_KEY_BASE dummy só aqui)
COPY . .
RUN rm -rf tmp/cache public/assets && \
    SECRET_KEY_BASE=dummy bundle exec rake assets:precompile

# ========================================
# Stage 2 — Runtime: imagem enxuta p/ produção
# ========================================
FROM ruby:3.2.4-slim

# Deps de runtime (libpq para pg, libvips p/ ActiveStorage, curl p/ healthcheck)
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  libpq5 libvips42 curl ca-certificates && \
  rm -rf /var/lib/apt/lists/*

# Usuário não-root
RUN useradd -m -u 1000 appuser
WORKDIR /app

# Copia dependências e app do builder
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app /app
RUN chown -R appuser:appuser /app
USER appuser

# Variáveis padrão (Render vai injetar PORT e suas envs)
ENV RAILS_ENV=production \
    RACK_ENV=production \
    NODE_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true \
    PORT=10000

EXPOSE 10000

# Healthcheck (Render usa o próprio Health Check Path, mas deixamos aqui também)
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s \
  CMD curl -fsS http://localhost:$PORT/up || exit 1

# Sobe Puma (limpa PID antes)
CMD ["/bin/sh", "-lc", "rm -f tmp/pids/server.pid && bundle exec puma -C config/puma.rb"]
