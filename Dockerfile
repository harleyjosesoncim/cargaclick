# syntax=docker/dockerfile:1
ARG RUBY_VERSION=3.2.4

# ========================================
# Stage 1 — Builder: gems, yarn e precompile
# ========================================
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

COPY Gemfile Gemfile.lock ./
# garante plataforma linux no lockfile para produção
RUN bundle lock --add-platform x86_64-linux || true
RUN bundle install --jobs 4 --retry 3

COPY package.json yarn.lock* ./
RUN yarn install --frozen-lockfile || true

COPY . .
RUN rm -rf tmp/cache public/assets \
 && SECRET_KEY_BASE=dummy bundle exec rails assets:precompile

# ========================================
# Stage 2 — Runtime: produção
# ========================================
FROM ruby:${RUBY_VERSION}-slim

# Somente libs de runtime (nada de compilar aqui)
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    libpq5 libvips42 tzdata postgresql-client \
 && rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV RAILS_ENV=production \
    RACK_ENV=production \
    NODE_ENV=production \
    RAILS_LOG_TO_STDOUT=1 \
    RAILS_SERVE_STATIC_FILES=1

COPY --from=builder /app /app
COPY --from=builder /usr/local/bundle /usr/local/bundle

# Entrypoint: prepara o banco e executa o comando
COPY docker/entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

EXPOSE 3000
CMD ["/usr/bin/entrypoint.sh", "bundle", "exec", "puma", "-C", "config/puma.rb"]
