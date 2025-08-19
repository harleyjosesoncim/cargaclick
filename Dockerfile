# =========================
# Etapa 1: Build (assets + gems)
# =========================
FROM ruby:3.2.4-slim AS builder

# Dependências de build
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential libpq-dev nodejs yarn libvips42 curl ca-certificates \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Bundler
RUN gem install bundler -v 2.6.9
RUN npm install -g yarn@1.22.22
# Configurar timezone (opcional, mas recomendado)

WORKDIR /app

# Ambiente / Bundler para build
ENV RAILS_ENV=production \
    RACK_ENV=production \
    NODE_ENV=production \
    BUNDLE_WITHOUT=development:test \
    BUNDLE_DEPLOYMENT=true \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3
    


# Garantir configs locais do Bundler (gravadas em /app/.bundle/config)
RUN bundle config set --local deployment 'true' \
 && bundle config set --local without 'development test'

# Copiar dependências Ruby e instalar
COPY Gemfile Gemfile.lock ./
RUN bundle install

# JS deps (precisamos de devDependencies para build dos assets)
COPY package.json yarn.lock* ./
RUN yarn install --check-files
# Instalar dependências JS adicionais
# Atualizar browserslist (opcional)
RUN npx update-browserslist-db@latest

# Copiar app e pré-compilar assets
COPY . .
ENV SECRET_KEY_BASE=dummy
RUN bundle exec rake assets:precompile

# =========================
# Etapa 2: Runtime (produção)
# =========================
FROM ruby:3.2.4-slim

# Dependências mínimas de execução
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    libpq-dev postgresql-client libvips42 curl ca-certificates \
 && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Usuário não-root
RUN useradd -m -u 1000 appuser
WORKDIR /app

# Copiar bundles e app do builder
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app /app

# Permissões
RUN chown -R appuser:appuser /app
USER appuser

# Instala Node.js, Yarn, etc
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor > /usr/share/keyrings/yarn.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list && \
    apt-get update -qq && \
    apt-get install -yq --no-install-recommends \
      nodejs yarn postgresql-client libpq-dev build-essential && \
    npm install -g yarn@1.22.22
# Limpar cache do apt

# Ambiente de runtime
ENV RAILS_ENV=production \
    RACK_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true \
    PORT=3000 \
    BUNDLE_WITHOUT=development:test \
    BUNDLE_DEPLOYMENT=true

EXPOSE 3000

# Healthcheck
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
  CMD curl -fsS "http://localhost:${PORT}/up" || exit 1

# Puma lê PORT de ENV no config/puma.rb; não use -b com ${PORT} em JSON form
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
