# Dockerfile completo para Rails 7 com ESBuild e TailwindCSS no Render

# 1. IMAGEM BASE: Use a imagem oficial do Ruby com a sua versão específica.
FROM ruby:3.2.4

# 2. VARIÁVEIS DE AMBIENTE ESSENCIAIS PARA PRODUÇÃO
ENV RAILS_ENV=production
ENV BUNDLE_WITHOUT="development:test"
ENV NODE_ENV=production

# 3. DIRETÓRIO DE TRABALHO: Define o diretório onde sua aplicação estará dentro do contêiner.
WORKDIR /app

# 4. DEPENDÊNCIAS DO SISTEMA E FERRAMENTAS:
#    - Instala Node.js 18.x e Yarn via repositórios oficiais (para versões mais recentes).
#    - Instala postgresql-client (para o banco de dados PostgreSQL).
#    - Instala libvips (para processamento de imagens com Active Storage).
#    - 'cmdtest-' garante que o Yarn antigo do apt não cause conflito.
#    - `rm -rf /var/lib/apt/lists/*` limpa o cache do APT para reduzir o tamanho da imagem.
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

# 5. DEPENDÊNCIAS JAVASCRIPT:
#    - Copia package.json e yarn.lock primeiro para otimizar o cache do Docker.
#    - `yarn install --frozen-lockfile --check-files` instala as dependências JS de forma limpa.
COPY package.json yarn.lock ./
RUN yarn install --frozen-lockfile --check-files

# 6. DEPENDÊNCIAS RUBY:
#    - Copia Gemfile e Gemfile.lock (para otimizar o cache).
#    - `bundle install` instala as gems. `--jobs $(nproc)` acelera a instalação.
COPY Gemfile Gemfile.lock ./
RUN bundle install --jobs $(nproc)

# 7. CÓDIGO DA APLICAÇÃO: Copia o restante do código para o diretório de trabalho.
COPY . .

# 8. PRÉ-COMPILAÇÃO DE ASSETS:
#    - `SECRET_KEY_BASE_DUMMY=1` é usado para permitir que o Rails inicialize sem a chave real durante o build.
#    - `yarn build` e `yarn build:css` chamam os scripts do package.json diretamente para compilar JS e CSS.
#    - `bundle exec rake assets:precompile` é mantido para que o Rails gere o manifest.json e outros assets do Sprockets.
RUN SECRET_KEY_BASE_DUMMY=1 yarn build && \
    SECRET_KEY_BASE_DUMMY=1 yarn build:css && \
    SECRET_KEY_BASE_DUMMY=1 bundle exec rake assets:precompile

# 9. EXPOSIÇÃO DE PORTA E COMANDO DE INICIALIZAÇÃO:
#    - `EXPOSE` informa a porta que a aplicação vai usar.
#    - `CMD` define o comando que será executado quando o contêiner iniciar (servidor Puma).
EXPOSE ${PORT}
CMD ["bundle", "exec", "rails", "server", "-b", "0.0.0.0", "-p", "${PORT}"]
