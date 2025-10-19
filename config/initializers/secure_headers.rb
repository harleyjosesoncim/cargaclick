# config/initializers/secure_headers.rb
# frozen_string_literal: true

SecureHeaders::Configuration.default do |config|
  # Domínios externos usados pelo app
  mp_domains  = %w[
    https://sdk.mercadopago.com
    https://www.mercadopago.com.br
    https://www.mercadopago.com
    https://api.mercadopago.com
    https://wallet.mercadopago.com
    https://*.mercadopago.com
    https://*.mercadopago.com.br
  ]

  osm_img    = %w[
    https://tile.openstreetmap.org
    https://*.tile.openstreetmap.org
    https://*.openstreetmap.org
  ]

  geo_apis   = %w[
    https://api.openrouteservice.org
    https://nominatim.openstreetmap.org
  ]

  cdn_libs   = %w[
    https://unpkg.com   # Alpine.js (se mantiver via CDN)
  ]

  # ------------------ CSP principal ------------------
  config.csp = {
    preserve_schemes: true,
    upgrade_insecure_requests: true,

    default_src: %w['self'],
    base_uri:    %w['self'],

    # JS: evite 'unsafe-eval'; mantenha 'unsafe-inline' até migrarmos p/ nonces
    script_src:  %w['self'] + cdn_libs + %w['unsafe-inline'],

    # CSS: Tailwind já vem minificado como arquivo; alguns admins usam inline
    style_src:   %w['self' 'unsafe-inline'],

    # Imagens: inclui tiles OSM e qualquer https (ícones, OG, etc)
    img_src:     %w['self' data: blob: https:] + osm_img,

    font_src:    %w['self' data:],

    # Conexões XHR/Fetch/WebSocket (ActionCable), geocoders e MP
    connect_src: %w['self' https: wss:] + geo_apis + mp_domains,

    # Iframes do checkout MP
    frame_src:   %w['self'] + mp_domains,

    # Submissões (ex.: redirecionamentos/forms para MP)
    form_action: %w['self'] + mp_domains,

    # WebWorkers (se usar)
    worker_src:  %w['self' blob:],

    # Bloqueios
    object_src:       %w['none'],
    frame_ancestors:  %w['self'] # quem pode embutir seu site
  }

  # ---------------- Cabeçalhos adicionais -------------
  config.hsts                     = "max-age=31536000; includeSubDomains; preload"
  config.x_frame_options          = "SAMEORIGIN"
  config.x_content_type_options   = "nosniff"
  config.x_xss_protection         = "1; mode=block"
  config.referrer_policy          = "strict-origin-when-cross-origin"

  # COOP/CORP: escolha segura que não quebra terceiros que você consome
  config.cross_origin_opener_policy   = "same-origin"
  config.cross_origin_resource_policy = "cross-origin"

  # (Opcional) Modo report-only e endpoint de report
  if ENV["CSP_REPORT_URI"].present?
    config.csp[:report_uri] = [ENV["CSP_REPORT_URI"]]
    config.csp_report_only  = ActiveModel::Type::Boolean.new.cast(ENV.fetch("CSP_REPORT_ONLY", "false"))
  end
end
