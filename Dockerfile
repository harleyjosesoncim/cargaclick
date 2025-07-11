# Dockerfile para Rails 7 + ESBuild + Tailwind (sem Sprockets)
FROM ruby:3.2.4

# Variáveis de ambiente básicas para produção
ENV RAILS_ENV=production \
    NODE_ENV=production \
    BUNDLE_WITHOUT="development:test" \
    PORT=10000

WORKDIR /app

# Instala Node.js 18.x, Yarn, PostgreSQL client, libvips (imagem), remove cache do apt
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor > /usr/share/keyrings/yarn.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list && \
    apt-get update -qq && \
    apt-get install -yq --no-install-recommends \
      nodejs yarn postgresql-client libvips && \
    rm -rf /var/lib/apt/lists/*

# Instala dependências JS primeiro (melhora o cache do build)
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --check-files

# Instala gems Ruby
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs $(nproc)

# Copia todo o restante do app para o container
COPY . .

# Gera os builds de JS/CSS (NÃO roda assets:precompile porque não tem Sprockets!)
RUN SECRET_KEY_BASE_DUMMY=1 yarn build && \
    SECRET_KEY_BASE_DUMMY=1 yarn build:css

EXPOSE ${PORT}
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
