# config/sitemap.rb — CargaClick
SitemapGenerator::Sitemap.default_host = "https://www.cargaclick.com.br"
SitemapGenerator::Sitemap.public_path  = "public/"
SitemapGenerator::Sitemap.compress     = true

SitemapGenerator::Sitemap.create do
  add '/',                     changefreq: 'daily',   priority: 1.0
  add '/fretes/novo',          changefreq: 'daily',   priority: 0.9
  add '/clientes/novo',        changefreq: 'monthly', priority: 0.6
  add '/transportadores/novo', changefreq: 'monthly', priority: 0.6
  # extras:
  add '/sobre',                changefreq: 'monthly', priority: 0.5
  add '/contato',              changefreq: 'monthly', priority: 0.4
  add '/termos-de-uso',        changefreq: 'monthly', priority: 0.3
end
