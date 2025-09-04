# ---- Stage 1: Build ----
FROM ruby:3.2.4 AS build

ARG RAILS_MASTER_KEY
ENV RAILS_MASTER_KEY=$RAILS_MASTER_KEY

ENV RAILS_ENV=production \
    NODE_ENV=production \
    BUNDLE_WITHOUT=development:test \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle

# Dependências para build
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    curl \
    git \
    tzdata \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs yarn \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Dependências Ruby
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 5

# Dependências JS
COPY package.json yarn.lock* ./
RUN yarn install --frozen-lockfile || true

# Copiar a aplicação
COPY . .

# Precompile de assets (com dummy key)
ENV SECRET_KEY_BASE=dummy_key
RUN bundle exec rake assets:precompile || echo "⚠️ Precompile falhou, prosseguindo..."

# ---- Stage 2: Runtime ----
FROM ruby:3.2.4-slim AS runtime

ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle

RUN apt-get update -qq && apt-get install -y \
    libpq5 \
    curl \
    tzdata \
    nodejs \
    yarn \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar gems e app
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app

# Porta padrão
EXPOSE 3000

# User não-root (opcional, mais seguro)
USER nobody

# Iniciar Puma
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
