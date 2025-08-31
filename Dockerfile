# ---- Stage 1: Build ----
FROM ruby:3.2.4 AS build

ARG RAILS_MASTER_KEY
ENV RAILS_MASTER_KEY=$RAILS_MASTER_KEY

# Variáveis de ambiente
ENV RAILS_ENV=production \
    NODE_ENV=production \
    BUNDLE_WITHOUT=development:test \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle

# Dependências para compilar gems + assets
RUN apt-get update -qq && apt-get install -y \
    build-essential \
    libpq-dev \
    nodejs \
    yarn \
    npm \
    git \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar arquivos de dependência primeiro (cache de build)
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs 4 --retry 5

COPY package.json yarn.lock* ./
RUN yarn install --check-files || true

# Copiar toda a aplicação
COPY . .

# Pré-compilar assets (Rails + Tailwind/JS)
RUN bundle exec rake assets:precompile

# ---- Stage 2: Runtime ----
FROM ruby:3.2.4 AS runtime

ENV RAILS_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true \
    BUNDLE_DEPLOYMENT=1 \
    BUNDLE_PATH=/usr/local/bundle

# Dependências mínimas para rodar Rails em produção
RUN apt-get update -qq && apt-get install -y \
    libpq-dev \
    nodejs \
    yarn \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copiar gems e aplicação do estágio build
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app

# Porta exposta
EXPOSE 3000

# Comando para iniciar o servidor Puma
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"]
