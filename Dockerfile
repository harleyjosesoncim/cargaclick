# syntax=docker/dockerfile:1
ARG RUBY_VERSION=3.2.4

# ===============================
# Stage 1 — Builder (gems + yarn)
# ===============================
FROM ruby:${RUBY_VERSION}-slim AS builder

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    curl ca-certificates gnupg build-essential git libpq-dev libvips42 pkg-config

# Node + Yarn só no builder
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
 && curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/yarn.gpg \
 && echo "deb [signed-by=/usr/share/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian stable main" > /etc/apt/sources.list.d/yarn.list \
 && apt-get update -qq && apt-get install -y --no-install-recommends nodejs yarn \
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

# Código da aplicação
COPY . .

# (Importante) NÃO faça assets:precompile na build!
# Apenas gere o CSS do Tailwind (opcional — ajuda no runtime)
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
    RAILS_SERVE_STATIC_FILES=1

# Copia app e gems do builder
COPY --from=builder /app /app
COPY --from=builder /usr/local/bu
