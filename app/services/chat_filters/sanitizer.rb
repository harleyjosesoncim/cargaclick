# frozen_string_literal: true

module ChatFilters
  class Sanitizer
    # Telefones brasileiros (com ou sem DDD, com ou sem +55)
    PHONE_REGEX   = /\b(?:\+?55\s*)?(?:\(?\d{2}\)?\s*)?(?:9?\d{4})-?\d{4}\b/

    # E-mails
    EMAIL_REGEX   = /\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i

    # URLs (http, https, www)
    URL_REGEX     = %r{\bhttps?://\S+|\bwww\.\S+}i

    # CPF e CNPJ
    CPF_REGEX     = /\b\d{3}\.?\d{3}\.?\d{3}-?\d{2}\b/
    CNPJ_REGEX    = /\b\d{2}\.?\d{3}\.?\d{3}\/?\d{4}-?\d{2}\b/

    # Sequências longas de dígitos (possível telefone/contato)
    LONG_DIGITS   = /\b\d{8,}\b/

    # Palavras que indicam tentativa de contato direto
    BLOCKED_WORDS = %w[
      zap whatsapp wpp whats zapp
      telefone telefonefixo celular contato fone
      liga ligar ligacao ligação chama chamar chamano
      pv privado direct dm
      instagram insta telegram tg
    ].freeze

    GENERIC_REPLACEMENT = "[dado de contato ocultado pelo CargaClick]"

    # Método principal: recebe o texto e devolve a versão sanitizada
    def self.call(text)
      return "" if text.blank?

      sanitized = text.to_s.dup

      [
        PHONE_REGEX,
        EMAIL_REGEX,
        URL_REGEX,
        CPF_REGEX,
        CNPJ_REGEX,
        LONG_DIGITS
      ].each do |regex|
        sanitized.gsub!(regex, GENERIC_REPLACEMENT)
      end

      BLOCKED_WORDS.each do |word|
        sanitized.gsub!(/#{Regexp.escape(word)}/i, GENERIC_REPLACEMENT)
      end

      sanitized.strip
    end
  end
end
