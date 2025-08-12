cat > config/sitemap.rb <<'RUBY'
SitemapGenerator::Sitemap.default_host = "https://www.cargaclick.com.br"
SitemapGenerator::Sitemap.public_path  = "public/"
SitemapGenerator::Sitemap.compress     = true

SitemapGenerator::Sitemap.create do
  add root_path,                   priority: 1.0, changefreq: "daily"
  add transportadores_path,        changefreq: "weekly"
  add clientes_path,               changefreq: "weekly"
  add fretes_path,                 changefreq: "daily"
  add propostas_path,              changefreq: "weekly"
  add bolsao_path,                 changefreq: "weekly"
  add ranking_path,                changefreq: "weekly"
  add cadastro_transportador_path, changefreq: "monthly"
end
RUBY
