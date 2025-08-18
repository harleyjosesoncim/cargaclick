# Etapa 1: Build (compilar assets e instalar dependências)
FROM ruby:3.2.4-slim AS builder

# Definir variáveis de ambiente para o build
ENV RAILS_ENV=production \
    RACK_ENV=production \
    BUNDLE_WITHOUT="development:test" \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3 \
    NODE_ENV=production

# Instalar dependências do sistema necessárias para o build
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    nodejs \
    npm \
    yarn \
    libvips42 \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Instalar versão específica do Bundler
RUN gem install bundler -v 2.6.9

# Definir diretório de trabalho
WORKDIR /app

# Copiar arquivos de dependências para aproveitar cache
COPY Gemfile Gemfile.lock ./
RUN bundle install

# Copiar arquivos de dependências JavaScript
COPY package.json yarn.lock* ./
RUN npm install -g yarn && yarn install --frozen-lockfile --production

# Atualizar banco de dados do Browserslist
RUN npx update-browserslist-db@latest

# Copiar o restante da aplicação
COPY . .

# Pré-compilar assets
ENV SECRET_KEY_BASE=dummy \
    APP_HOST=build.local \
    APP_PROTOCOL=https
RUN bundle exec rake assets:precompile

# Etapa 2: Imagem final (runtime)
FROM ruby:3.2.4-slim

# Instalar dependências mínimas para runtime
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    libpq-dev \
    postgresql-client \
    libvips42 \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Criar usuário não-root para maior segurança
RUN useradd -m -u 1000 appuser

# Definir diretório de trabalho
WORKDIR /app

# Copiar artefatos da etapa de build
COPY --from=builder /usr/local/bundle /usr/local/bundle
COPY --from=builder /app /app

# Ajustar permissões
RUN chown -R appuser:appuser /app
USER appuser

# Configurações de runtime
ENV RAILS_ENV=production \
    RACK_ENV=production \
    RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true \
    PORT=3000

# Expor porta padrão
EXPOSE 3000

# Healthcheck para monitoramento
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s \
    CMD curl -f http://localhost:${PORT}/up || exit 1

# Iniciar o servidor Puma
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb", "-b", "tcp://0.0.0.0:${PORT}"]