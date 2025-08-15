# Dockerfile
FROM ruby:3.2.4

# 1) Variáveis que afetam a instalação de gems (antes do bundle install!)
ENV RAILS_ENV=production \
    RACK_ENV=production \
    BUNDLE_WITHOUT="development:test" \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3

# 2) Dependências do SO (inclui libpq-dev para a gem pg e libvips para image_processing)
RUN apt-get update -y && apt-get install -y --no-install-recommends \
  build-essential \
  libpq-dev \
  postgresql-client \
  nodejs \
  npm \
  libvips \
  && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# 3) Gems com cache de camadas
COPY Gemfile Gemfile.lock ./
RUN bundle install

# 4) Front-end (aproveita cache da camada)
COPY package.json yarn.lock* ./
RUN [ -f yarn.lock ] && npm i -g yarn && yarn install --frozen-lockfile || true

# 5) Copia o app
COPY . .

# 6) Variáveis apenas para o build (Render injeta as reais em runtime)
ENV SECRET_KEY_BASE=dummy \
    APP_HOST=build.local \
    APP_PROTOCOL=https

# 7) Precompile de assets (o rake já dispara js/css do jsbundling/cssbundling)
RUN bundle exec rake assets:precompile

# 8) Config de runtime
ENV RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true

# 9) Start do servidor
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb", "-b", "tcp://0.0.0.0:${PORT}"]
# 10) Expor a porta padrão do Puma
