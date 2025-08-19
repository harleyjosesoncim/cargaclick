# ========================================
# Etapa 1: Build - Gems, Yarn, Assets
# ========================================
FROM ruby:3.2.4-slim AS builder

# Instalar dependências para build (incluindo Node.js + Yarn)
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    curl ca-certificates gnupg && \
    curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/yarn.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list && \
    apt-get update -qq && apt-get install -y --no-install-recommends \
    nodejs yarn build-essential libpq-dev libvips42 git && \
    rm -rf /var/lib/apt/lists/*

# Definir diretório da app
WORKDIR /app

# Configurações do Bundler para produção
ENV RAILS_ENV=production \
    NODE_ENV=production \
    BUNDLE_WITHOUT=development:test \
    BUNDLE_DEPLOYMENT=true \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3

# Configuração local do bundler (redundância útil)
RUN bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test'

# Copiar Gemfiles e instalar as gems
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Instalar dependências JS
COPY package.json yarn.lock* ./
RUN yarn install --check-files && \
    npx update-browserslist-db@latest || true

# Copiar restante do app e pré-compilar os assets
COPY . .
ENV SECRET_KEY_BASE=dummy
RUN bundle exec rake assets:precompile

# ========================================
# Etapa 2: Runtime - Execução da App
# ========================================
FROM ruby:3.2.4-slim

# Instalar dependências mínimas para produção
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    libpq-dev postgresql-client libvips42 curl ca-certificates && \
    rm -rf /var/lib/apt/lists/*

# Criar usuário não-root seguro
RUN useradd -m -u 1000 appuser
WORKDIR /app

# Copiar app e gems da etapa de build
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app /app

# Ajustar permissões
RUN chown -R appuser:appuser /app
USER appuser

# Configurações de ambiente
ENV RAILS_ENV=production \
    RACK_ENV=production \
    NODE_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true \
    BUNDLE_WITHOUT=development:test \
    BUNDLE_DEPLOYMENT=true \
    PORT=3000

EXPOSE 3000

# Healthcheck padrão
HEALTHCHECK --interval=30s --timeout=5s --start-period=10s \
  CMD curl -fsS http://localhost:$PORT/up || exit 1

# Comando final de execução
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
