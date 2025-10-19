# config/initializers/secure_headers.rb
# frozen_string_literal: true

SecureHeaders::Configuration.default do |config|
  # Domínios externos usados pelo app
  mp  = %w[
    https://sdk.mercadopago.com
    https://www.mercadopago.com.br
    https://www.mercadopago.com
    https://api.mercadopago.com
    https://wallet.mercadopago.com
    https://*.mercadopago.com
    https://*.mercadopago.com.br
  ]

  osm = %w[
    https://tile.openstreetmap.org
    https://*.tile.openstreetmap.org
    https://*.openstreetmap.org
  ]

  geo = %w[
    https://api.openrouteservice.org
    https://nominatim.openstreetmap.org
  ]

  # Se precisar de Alpine via CDN, habilite com ALLOW_CDN=true
  cdn = ENV["ALLOW_CDN"] == "true" ? %w[https://unpkg.com] : []

  config.csp = {
    preserve_schemes: true,
    upgrade_insecure_requests: true,

    default_src: %w['self'],
    base_uri:    %w['self'],

    # Evite 'unsafe-eval'. Mantemos 'unsafe-inline' até migrar para nonces.
    script_src:  %w['self' 'unsafe-inline'] + cdn,
    style_src:   %w['self' 'unsafe-inline'],

    img_src:     %w['self' data: blob: https:] + osm,
    font_src:    %w['self' data:],
    connect_src: %w['self' https: wss:] + geo + mp,
    frame_src:   %w['self'] + mp,
    form_action: %w['self'] + mp,
    worker_src:  %w['self' blob:],
    object_src:  %w['none'],
    frame_ancestors: %w['self'],

    # Report-only opcional
    report_uri: (ENV["CSP_REPORT_URI"].present? ? [ENV["CSP_REPORT_URI"]] : nil)
  }.compact

  # Cabeçalhos complementares
  config.hsts                     = "max-age=31536000; includeSubDomains; preload"
  config.x_frame_options          = "SAMEORIGIN"
  config.x_content_type_options   = "nosniff"
  config.x_xss_protection         = "1; mode=block"
  config.referrer_policy          = "strict-origin-when-cross-origin"

  # NÃO chamar config.cross_origin_opener_policy / resource_policy (não existem nesta versão)
end

# Se quiser COOP/CORP mesmo assim, defina via Rails (independe do secure_headers):
Rails.application.config.action_dispatch.default_headers.merge!(
  "Cross-Origin-Opener-Policy"   => "same-origin",
  "Cross-Origin-Resource-Policy" => "cross-origin"
)
