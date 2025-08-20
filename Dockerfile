# ========================================
# Stage 1 — Builder: gems, yarn e precompile
# ========================================
FROM ruby:3.2.4-slim AS builder

RUN apt-get update -qq && apt-get install -y --no-install-recommends \
  curl ca-certificates gnupg build-essential git libpq-dev libvips42 && \
  curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
  curl -fsSL https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor -o /usr/share/keyrings/yarn.gpg && \
  echo "deb [signed-by=/usr/share/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian stable main" > /etc/apt/sources.list.d/yarn.list && \
  apt-get update -qq && apt-get install -y --no-install-recommends nodejs yarn && \
  rm -rf /var/lib/apt/lists/*

WORKDIR /app

ENV RAILS_ENV=production \
    NODE_ENV=production \
    BUNDLE_WITHOUT=development:test \
    BUNDLE_DEPLOYMENT=true \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3

COPY Gemfile Gemfile.lock ./
RUN bundle install

COPY package.json yarn.lock* ./
RUN yarn install --frozen-lockfile || true

COPY . .
RUN rm -rf tmp/cache public/assets && \
    SECRET_KEY_BASE=dummy bundle exec rake assets:precompile

# ========================================
# Stage 2 — Runtime: produção
# ========================================
FROM ruby:3.2.4-slim

RUN apt-get update -qq && apt-get install -y --no-install-recommends