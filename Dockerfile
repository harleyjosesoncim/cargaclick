# Use a imagem oficial do Ruby
FROM ruby:3.2.4

# Define variáveis de ambiente essenciais para produção
ENV RAILS_ENV=production
ENV BUNDLE_WITHOUT="development:test"
ENV NODE_ENV=production

# Instala dependências do sistema, o Yarn correto, e remove o pacote conflitante
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | gpg --dearmor > /usr/share/keyrings/yarn.gpg && \
    echo "deb [signed-by=/usr/share/keyrings/yarn.gpg] https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list && \
    apt-get update -qq && \
    apt-get install -yq --no-install-recommends \
    nodejs \
    yarn \
    postgresql-client \
    libvips \
    cmdtest- && \
    rm -rf /var/lib/apt/lists/*

# Define o diretório de trabalho
WORKDIR /app

# Instala dependências do Node.js (aproveitando o cache do Docker)
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --check-files

# Instala gems do Ruby (aproveitando o cache do Docker)
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs $(nproc)

# Copia o restante do código da aplicação
COPY . .

# Pré-compila TODOS os assets da forma correta para produção
RUN SECRET_KEY_BASE_DUMMY=1 bundle exec rake assets:precompile

# Expõe a porta e define o comando para iniciar o servidor
EXPOSE 3000
CMD ["./bin/rails", "server", "-b", "0.0.0.0"]