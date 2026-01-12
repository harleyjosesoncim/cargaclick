# frozen_string_literal: true

require "base64"
require "tempfile"

Rails.application.config.after_initialize do
  begin
    next if ENV["EFI_CLIENT_ID"].blank?

    base64 = ENV["EFI_CERT_BASE64"]
    raise "EFI_CERT_BASE64 ausente" if base64.blank?

    decoded = Base64.decode64(base64)

    cert_file = Tempfile.new(["efi_cert", ".p12"])
    cert_file.binmode
    cert_file.write(decoded)
    cert_file.close

    module Pagamentos
      module Efi
        mattr_accessor :config
      end
    end

    Pagamentos::Efi.config = {
      client_id:     ENV["EFI_CLIENT_ID"],
      client_secret: ENV["EFI_CLIENT_SECRET"],
      certificate:   cert_file.path,
      sandbox:       ENV.fetch("EFI_ENV", "sandbox") == "sandbox",
      timeout:       30
    }

    Rails.logger.info("[EFI] Pagamentos::Efi.config carregado com sucesso")
  rescue => e
    Rails.logger.error("[EFI] Falha ao inicializar EfiBank: #{e.class} - #{e.message}")
  end
end
