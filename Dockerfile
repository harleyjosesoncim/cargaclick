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
=======
# Copiar arquivos de gems
>>>>>>> 7b6c8d2 (Docker fixes)
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

<<<<<<< HEAD
# Yarn cache
>>>>>>> 54ddf36 (x)
COPY package.json yarn.lock* ./

<<<<<<< HEAD
=======
# Copiar manifestos do frontend
COPY package.json yarn.lock* ./

>>>>>>> 7b6c8d2 (Docker fixes)
# Instalar dependências JS (compatível com Yarn 1.x do Render)
RUN yarn install --check-files || true

# ⚠️ removido o "npx update-browserslist-db" que estava quebrando

# Copiar o restante da aplicação
<<<<<<< HEAD
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
=======
>>>>>>> 7b6c8d2 (Docker fixes)
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
<<<<<<< HEAD
CMD ["/usr/bin/entrypoint.sh", "bundle", "exec", "puma", "-C", "config/puma.rb"]
>>>>>>> 54ddf36 (x)
=======

# Comando para iniciar o servidor Puma
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
>>>>>>> 7b6c8d2 (Docker fixes)
