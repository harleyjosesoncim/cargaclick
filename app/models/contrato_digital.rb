# frozen_string_literal: true

class ContratoDigital < ApplicationRecord
  # =====================================================
  # CONFIGURAÇÃO DE TABELA (pluralização PT-BR)
  # =====================================================
  self.table_name = "contratos_digitais"

  # =====================================================
  # ASSOCIAÇÕES
  # =====================================================
  belongs_to :frete
  belongs_to :cliente
  belongs_to :transportador

  # =====================================================
  # STATUS JURÍDICO DO CONTRATO
  # =====================================================
  enum status: {
    pendente: "pendente",
    aceito:   "aceito",
    cancelado: "cancelado"
  }, _default: "pendente"

  # =====================================================
  # VALIDAÇÕES
  # =====================================================
  validates :hash_documento, presence: true, uniqueness: true
  validates :frete_id, :cliente_id, :transportador_id, presence: true
  validates :status, presence: true

  # =====================================================
  # CALLBACKS
  # =====================================================
  before_validation :gerar_hash_documento, on: :create

  # =====================================================
  # AÇÕES DE DOMÍNIO (contrato)
  # =====================================================
  def aceitar!(ip:, user_agent:)
    raise "Contrato já aceito" if aceito?

    update!(
      status: "aceito",
      aceito_em: Time.current,
      aceito_ip: ip,
      aceito_user_agent: user_agent
    )
  end

  def aceito?
    status == "aceito" && aceito_em.present?
  end

  # =====================================================
  # AUDITORIA / DEBUG
  # =====================================================
  def to_s
    "📄 Contrato ##{id} | Frete ##{frete_id} | Cliente ##{cliente_id} | " \
      "Transportador ##{transportador_id} | Status: #{status}"
  end

  private

  # =====================================================
  # HASH JURÍDICO DO DOCUMENTO
  #
  # - Garante integridade
  # - Serve como prova digital
  # - Pode ser usado em cartório, arbitragem ou disputa
  # =====================================================
  def gerar_hash_documento
    return if hash_documento.present?

    payload = [
      frete_id,
      cliente_id,
      transportador_id,
      Time.current.to_i,
      SecureRandom.uuid
    ].join(":")

    self.hash_documento = Digest::SHA256.hexdigest(payload)
  end
end
