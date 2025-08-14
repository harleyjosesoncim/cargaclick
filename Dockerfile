# Dockerfile
FROM ruby:3.2.4

# Dependências do SO
RUN apt-get update -y && apt-get install -y --no-install-recommends \
  build-essential \
  nodejs \
  npm \
  postgresql-client \
  libvips \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 1) Bundler (precisa do Gemfile)
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs=4 --retry=3

# 2) Yarn (se houver front-end)
COPY package.json yarn.lock* ./
RUN [ -f yarn.lock ] && npm i -g yarn && yarn install --frozen-lockfile || true

# 3) App inteiro
COPY . .

# 4) Variáveis só para o build (o Render injeta as reais em runtime)
ENV RAILS_ENV=production \
    SECRET_KEY_BASE=dummy \
    APP_HOST=build.local \
    APP_PROTOCOL=https

# 5) Build dos assets (esbuild/tailwind) + precompile
# (se você chama yarn build/build:css em outros scripts, mantenha;
# o precompile já dispara tasks js/css em Rails 7 com jsbundling/cssbundling)
RUN yarn build || true && yarn build:css || true
RUN bundle exec rake assets:precompile

# 6) Servidor (ajuste se tiver puma.rb)
ENV RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
