# Usar a imagem oficial do Ruby 3.2.4
FROM ruby:3.2.4

# 1) Definir variáveis de ambiente para o build
ENV RAILS_ENV=production \
    RACK_ENV=production \
    BUNDLE_WITHOUT="development:test" \
    BUNDLE_JOBS=4 \
    BUNDLE_RETRY=3

# 2) Instalar dependências do sistema operacional
RUN apt-get update -qq && apt-get install -y --no-install-recommends \
    build-essential \
    libpq-dev \
    postgresql-client \
    nodejs \
    npm \
    yarn \
    libvips \
    && rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# 3) Definir diretório de trabalho
WORKDIR /app

# 4) Copiar Gemfile e Gemfile.lock para aproveitar cache
COPY Gemfile Gemfile.lock ./

# 5) Instalar gems com Bundler
RUN gem install bundler -v 2.6.9 && bundle install

# 6) Copiar package.json e yarn.lock (se existir) para instalar dependências JS
COPY package.json yarn.lock* ./
RUN npm install -g yarn && yarn install --frozen-lockfile

# 7) Atualizar banco de dados do Browserslist para evitar aviso
RUN npx update-browserslist-db@latest

# 8) Copiar o restante da aplicação
COPY . .

# 9) Definir variáveis de ambiente para pré-compilação de assets
ENV SECRET_KEY_BASE=dummy \
    APP_HOST=build.local \
    APP_PROTOCOL=https

# 10) Pré-compilar assets (JavaScript e CSS via jsbundling-rails/cssbundling-rails)
RUN bundle exec rake assets:precompile

# 11) Configurações de runtime
ENV RAILS_LOG_TO_STDOUT=true \
    RAILS_SERVE_STATIC_FILES=true

# 12) Expor a porta padrão (3000, usada pelo Render)
EXPOSE 3000

# 13) Iniciar o servidor Puma com configuração personalizada
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb", "-b", "tcp://0.0.0.0:${PORT:-3000}"]
