FROM ruby:3.2.4

ENV RAILS_ENV=production \
    RACK_ENV=production \
    NODE_ENV=production \
    BUNDLE_WITHOUT="development:test" \
    RAILS_SERVE_STATIC_FILES=true \
    PORT=10000

WORKDIR /app

ENV RAILS_ENV=production \
    RACK_ENV=production \
    NODE_ENV=production \
    RAILS_SERVE_STATIC_FILES=true \
    SECRET_KEY_BASE=dummy \
    DATABASE_URL=postgresql://postgres:postgres@localhost:5432/dummy \
    APP_HOST=build.local

RUN bundle exec rake assets:precompile
# dependências do sistema


# deps
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get update -qq && \
    apt-get install -y --no-install-recommends \
      nodejs postgresql-client libpq-dev build-essential libvips && \
    rm -rf /var/lib/apt/lists/*

# gems
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs=4 --retry=3

# node/yarn
COPY package.json yarn.lock* ./
RUN [ -f yarn.lock ] && npm i -g yarn && yarn install --frozen-lockfile || true

# código
COPY . .

# bundling (js/css) — opcional, mas ajuda no cache
RUN yarn build || true && yarn build:css || true

# PRECOMPILE sprockets (gera public/assets + manifest)
# usa SECRET_KEY_BASE dummy só no build; em runtime o Render injeta a real
ENV SECRET_KEY_BASE=dummy
RUN bundle exec rake assets:precompile

# servidor
CMD ["bash","-lc","bundle exec puma -C config/puma.rb"]
