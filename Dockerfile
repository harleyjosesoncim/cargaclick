# ---- Stage 1: Build ----
FROM ruby:3.2.4 AS build

ARG RAILS_MASTER_KEY
ENV RAILS_MASTER_KEY $RAILS_MASTER_KEY

# Variáveis de ambiente
ENV RAILS_ENV=production \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle

# Instalar dependências básicas
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    yarn \
    npm \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

<<<<<<< HEAD
# Copiar arquivos de gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

# Copiar manifestos do frontend
=======
ENV RAILS_ENV=production \
    NODE_ENV=production \
    BUNDLE_WITHOUT=development:test \
    BUNDLE_DEPLOYMENT=1

# Bundler cache
COPY Gemfile Gemfile.lock ./
RUN bundle lock --add-platform x86_64-linux || true
RUN bundle install --jobs 4 --retry 3

# Yarn cache
>>>>>>> 54ddf36 (x)
COPY package.json yarn.lock* ./

<<<<<<< HEAD
# Instalar dependências JS (compatível com Yarn 1.x do Render)
RUN yarn install --check-files || true

# ⚠️ removido o "npx update-browserslist-db" que estava quebrando

# Copiar o restante da aplicação
COPY . .

# Pré-compilar assets
RUN bundle exec rake assets:precompile

# ---- Stage 2: Runtime ----
FROM ruby:3.2.4 AS runtime

ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle

# Dependências mínimas para runtime
RUN apt-get update -qq && apt-get install -y \
    libpq-dev \
    nodejs \
    yarn \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar gems e app do estágio build
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app

# Expor a porta
EXPOSE 3000

# Comando para iniciar o servidor Puma
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
=======
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
>>>>>>> 54ddf36 (x)
