# config/initializers/secure_headers.rb
# frozen_string_literal: true

SecureHeaders::Configuration.default do |config|
  # Conteúdo permitido (mínimo para não quebrar)
  config.csp = {
    default_src: %w['self'],
    script_src: %w['self' 'unsafe-inline' 'unsafe-eval'],
    style_src: %w['self' 'unsafe-inline'],
    img_src: %w['self' data: blob:],
    font_src: %w['self' data:],
    connect_src: %w['self'],
    frame_src: %w['self'],
    object_src: %w['none']
  }

  # Cabeçalhos extras de segurança
  config.hsts = "max-age=31536000; includeSubDomains"
  config.x_frame_options = "SAMEORIGIN"
  config.x_content_type_options = "nosniff"
  config.x_xss_protection = "1; mode=block"
  config.referrer_policy = "strict-origin-when-cross-origin"
end
