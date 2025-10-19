# Cache store robusto: usa Redis se REDIS_URL existir; senão cai para memory_store
# Também adiciona namespace, timeouts, pool e tratamento de erros.

redis_url = ENV["REDIS_URL"]

# Nome/namespace do app para isolar caches por ambiente
app_namespace = Rails.application.class.module_parent_name.to_s.underscore.presence || "app"
cache_namespace = ENV.fetch("REDIS_NAMESPACE", "#{app_namespace}_cache_#{Rails.env}")

if redis_url.present?
  # Opções padrão seguras para produção
  pool_size    = Integer(ENV.fetch("RAILS_MAX_THREADS", 5))
  pool_timeout = Integer(ENV.fetch("REDIS_POOL_TIMEOUT", 5))
  connect_to   = Float(ENV.fetch("REDIS_CONNECT_TIMEOUT", 2.0))
  read_to      = Float(ENV.fetch("REDIS_READ_TIMEOUT", 1.0))
  write_to     = Float(ENV.fetch("REDIS_WRITE_TIMEOUT", 1.0))
  default_ttl  = Integer(ENV.fetch("CACHE_DEFAULT_TTL", 86_400)) # 24h

  opts = {
    url: redis_url,
    namespace: cache_namespace,
    reconnect_attempts: Integer(ENV.fetch("REDIS_RECONNECT_ATTEMPTS", 3)),
    pool_size: pool_size,
    pool_timeout: pool_timeout,
    connect_timeout: connect_to,
    read_timeout: read_to,
    write_timeout: write_to,
    compress: true,
    compression_threshold: 4.kilobytes,
    expires_in: default_ttl,
    error_handler: ->(method:, returning:, exception:) do
      Rails.logger.warn "Redis cache error: #{method} returning=#{returning} #{exception.class}: #{exception.message}"
    end
  }

  # TLS (rediss://)
  if redis_url.start_with?("rediss://")
    ssl_verify = ENV.fetch("REDIS_SSL_VERIFY_MODE", "peer") # "peer" | "none"
    verify_mode =
      case ssl_verify
      when "none" then OpenSSL::SSL::VERIFY_NONE
      else             OpenSSL::SSL::VERIFY_PEER
      end

    opts[:ssl_params] = { verify_mode: verify_mode }
    ca_file = ENV["REDIS_SSL_CA_FILE"]
    opts[:ssl_params][:ca_file] = ca_file if ca_file.present?
  end

  # Aviso amigável caso alguém tenha deixado o placeholder de exemplo
  if redis_url.include?("redis://host:6379") || redis_url.include?("redis://localhost:6379")
    Rails.logger.warn "REDIS_URL parece apontar para um host de exemplo. Ajuste para o endpoint real do seu provedor."
  end

  Rails.application.config.cache_store = :redis_cache_store, opts
else
  # Fallback (não recomendado em multi-instância/dyno)
  mem_size_mb = Integer(ENV.fetch("MEMORY_STORE_SIZE_MB", 64))
  Rails.logger.warn "REDIS_URL ausente; usando :memory_store (#{mem_size_mb}MB) como fallback"
  Rails.application.config.cache_store = :memory_store, { size: mem_size_mb.megabytes }
end

