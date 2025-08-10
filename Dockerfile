# Dockerfile para Rails 7 + ESBuild + Tailwind (sem precompile em build)
FROM ruby:3.2.4

# Variáveis de ambiente
ENV RAILS_ENV=production \
    RACK_ENV=production \
    NODE_ENV=production \
    BUNDLE_WITHOUT="development:test" \
    RAILS_SERVE_STATIC_FILES=true \
    RAILS_LOG_TO_STDOUT=true \
    PORT=10000

WORKDIR /app

# Node.js + Yarn + deps do PostgreSQL/libvips (e headers p/ gems nativas)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor > /usr/share/keyrings/yarn.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list && \
    apt-get update -qq && \
    apt-get install -yq --no-install-recommends \
      nodejs yarn postgresql-client libpq-dev build-essential libvips && \
    rm -rf /var/lib/apt/lists/*

# Dependências Ruby (melhor cache)
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs $(nproc)

# Dependências JS (melhor cache)
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --check-files

# Copia apenas o necessário para buildar os assets (melhor cache)
COPY app/assets/ app/assets/
COPY app/javascript/ app/javascript/
COPY config/tailwind.config.js config/tailwind.config.js

# Copia o restante do app
COPY . .

# Build do JS/CSS (esbuild + tailwind) -> gera app/assets/builds/*
RUN yarn build && yarn build:css

# Observação: sem `rails assets:precompile` aqui.
# Os assets fingerprintados de `public/assets` já estão versionados
# e serão servidos em produção por `RAILS_SERVE_STATIC_FILES=true`.

EXPOSE ${PORT}
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
