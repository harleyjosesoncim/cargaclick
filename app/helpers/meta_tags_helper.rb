# frozen_string_literal: true

module MetaTagsHelper
  # Define meta tags dinâmicas com fallback para valores padrão
  def meta_title(page_title = nil)
    base_title = "CargaClick — Fretes rápidos e confiáveis"
    page_title.present? ? "#{page_title} | CargaClick" : base_title
  end

  def meta_description(page_description = nil)
    default_description = "Simule fretes, compare preços e prazos com transportadores da sua região em poucos cliques. CargaClick conecta você ao melhor transporte."
    page_description.presence || default_description
  end

  def meta_image(image = nil)
    # fallback para uma imagem OG padrão em app/assets/images
    image.presence || asset_url("cargaclick_og.png")
  end

  def render_meta_tags(title: nil, description: nil, image: nil, url: nil)
    tag.title(meta_title(title)) +
      tag.meta(name: "description", content: meta_description(description)) +

      # Open Graph
      tag.meta(property: "og:type", content: "website") +
      tag.meta(property: "og:url", content: url || request.original_url) +
      tag.meta(property: "og:title", content: meta_title(title)) +
      tag.meta(property: "og:description", content: meta_description(description)) +
      tag.meta(property: "og:image", content: meta_image(image)) +

      # Twitter
      tag.meta(name: "twitter:card", content: "summary_large_image") +
      tag.meta(name: "twitter:title", content: meta_title(title)) +
      tag.meta(name: "twitter:description", content: meta_description(description)) +
      tag.meta(name: "twitter:image", content: meta_image(image))
  end
end
