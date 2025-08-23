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


# Copiar Gemfile e Gemfile.lock para cache
COPY Gemfile Gemfile.lock ./

# Instalar bundler na versão especificada no Gemfile.lock
RUN gem install bundler:2.6.9

# Adicionar plataformas necessárias antes do install
RUN bundle lock --add-platform ruby x86_64-linux

# Configurar e instalar gems
RUN bundle config set force_ruby_platform true \
 && bundle config set without 'development test' \
 && bundle install --jobs 4 --retry 3

# Instalar dependências de frontend
COPY package.json yarn.lock* ./
RUN yarn install --frozen-lockfile || true
RUN npx update-browserslist-db@latest

# Copiar o aplicativo
COPY . .

# Pré-compilar assets
RUN SECRET_KEY_BASE=dummy bundle exec rake assets:precompile

# ---------- RUNTIME STAGE ----------
FROM ruby:3.2.4-slim AS app

ENV RAILS_ENV=production \
    RACK_ENV=production \
    GEM_HOME=/usr/local/bundle \
    BUNDLE_PATH=/usr/local/bundle \
    PATH="/usr/local/bundle/bin:${PATH}"

# Instalar dependências mínimas para runtime
RUN apt-get update -y && apt-get install -y --no-install-recommends \
    libpq5 nodejs curl \
 && rm -rf /var/lib/apt/lists/*

# Instalar bundler no runtime
RUN gem install bundler:2.6.9

ENV PATH="/app/bin:$PATH"


WORKDIR /app
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app

# Verificar se o comando rails está disponível
RUN bundle exec rails --version

# Copiar e configurar script de entrada
COPY docker/entrypoint.sh /usr/bin/entrypoint.sh
RUN chmod +x /usr/bin/entrypoint.sh

EXPOSE 3000
ENTRYPOINT ["/usr/bin/entrypoint.sh"]
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]