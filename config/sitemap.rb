cat > config/sitemap.rb <<'RUBY'
SitemapGenerator::Sitemap.default_host = "https://www.cargaclick.com.br"
SitemapGenerator::Sitemap.public_path  = "public/"
SitemapGenerator::Sitemap.compress     = true

SitemapGenerator::Sitemap.create do
  add '/',                      changefreq: 'daily',   priority: 1.0
  add '/fretes/novo',           changefreq: 'daily',   priority: 0.9
  add '/clientes/novo',         changefreq: 'monthly', priority: 0.6
  add '/transportadores/novo',  changefreq: 'monthly', priority: 0.6
  # add outras rotas públicas aqui, ex:
  # add '/ranking',             changefreq: 'weekly'
end
RUBY
# This file is used to configure the sitemap generation for the CargoClick application.
