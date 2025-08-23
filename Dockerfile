# ---------- BUILD STAGE ----------
FROM ruby:3.2.4-slim AS build

ENV RAILS_ENV=production \
    RACK_ENV=production \
    BUNDLE_WITHOUT="development:test" \
    GEM_HOME=/usr/local/bundle \
    BUNDLE_PATH=/usr/local/bundle \
    PATH="/usr/local/bundle/bin:${PATH}"
    ENV PATH="/app/bin:$PATH"


# Instalar dependências de build
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    build-essential git libpq-dev nodejs yarn curl \
    libssl-dev zlib1g-dev pkg-config \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV RAILS_ENV=production \
    NODE_ENV=production \
    BUNDLE_WITHOUT=development:test \
    BUNDLE_DEPLOYMENT=1

# Bundler cache
COPY Gemfile Gemfile.lock ./
RUN bundle lock --add-platform x86_64-linux || true
RUN bundle install --jobs 4 --retry 3

# Yarn cache
COPY package.json yarn.lock* ./
RUN yarn install --frozen-lockfile || true
RUN npx update-browserslist-db@latest

# Código da aplicação
COPY . .

# Builda JS e CSS (para não precisar de Node no runtime)
RUN yarn build:js || yarn build
RUN yarn build:css || true

# ===============================
# Stage 2 — Runtime (produção)
# ===============================
FROM ruby:${RUBY_VERSION}-slim

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    libpq5 libvips42 tzdata postgresql-client \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV RAILS_ENV=production \
    RACK_ENV=production \
    NODE_ENV=production \
    RAILS_LOG_TO_STDOUT=1 \
    RAILS_SERVE_STATIC_FILES=1 \
    PATH="/usr/local/bundle/bin:${PATH}"

# Copia app e gems do builder
COPY --from=builder /app /app
COPY --from=builder /usr/local/bundle/ /usr/local/bundle/

# Entrypoint: migra DB e precompila assets no runtime
COPY docker/entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

EXPOSE 3000
CMD ["/usr/bin/entrypoint.sh", "bundle", "exec", "puma", "-C", "config/puma.rb"]
