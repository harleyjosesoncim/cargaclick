# Dockerfile para Rails 7 + ESBuild + Tailwind (sem Sprockets)
FROM ruby:3.2.4

# Variáveis de ambiente
ENV RAILS_ENV=production \
    NODE_ENV=production \
    BUNDLE_WITHOUT="development:test" \
    PORT=10000

WORKDIR /app

# Instala Node.js, Yarn, PostgreSQL client, libvips (imagem)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor > /usr/share/keyrings/yarn.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list && \
    apt-get update -qq && \
    apt-get install -yq --no-install-recommends \
      nodejs yarn postgresql-client libvips && \
    rm -rf /var/lib/apt/lists/*

# Copia os arquivos de dependências
COPY Gemfile Gemfile.lock ./
COPY package.json yarn.lock ./

# Instala gems e dependências JS
RUN bundle install --jobs $(nproc)
RUN yarn install --frozen-lockfile --check-files

# Copia apenas os arquivos essenciais para o build dos assets
COPY app/assets/ app/assets/
COPY app/javascript/ app/javascript/
COPY config/tailwind.config.js config/tailwind.config.js

# Copia o restante do app
COPY . .

# Builda JS e CSS dentro do container
RUN yarn build && yarn build:css

EXPOSE ${PORT}
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0"]
