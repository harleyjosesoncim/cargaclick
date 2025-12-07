# frozen_string_literal: true

class Message < ApplicationRecord
  # === ASSOCIAÇÕES ==================================
  belongs_to :frete
  belongs_to :sender, polymorphic: true   # Cliente, Transportador ou AdminUser

  # === VALIDAÇÕES ===================================
  validates :content, presence: true, length: { minimum: 1, maximum: 2000 }
  validates :sender_type, :sender_id, presence: true

  # === STATUS (enum) ================================
  enum status: {
    normal: 0,     # mensagem comum
    lido: 1,       # já visualizada
    importante: 2  # destaque
  }, _default: :normal

  # === BROADCAST (Turbo Streams) ====================
  after_create_commit -> { broadcast_append_to "frete_#{frete_id}_messages" }

  # === CALLBACKS ====================================
  # Antes de validar/salvar, passa o texto pelo filtro de segurança
  before_validation :sanitize_content

  # === SCOPES =======================================
  scope :recent,           -> { order(created_at: :asc) }
  scope :do_cliente,       -> { where(sender_type: "Cliente") }
  scope :do_transportador, -> { where(sender_type: "Transportador") }
  scope :do_admin,         -> { where(sender_type: "AdminUser") }
  scope :nao_lidas,        -> { where(status: :normal) }

  # === MÉTODOS DE AÇÃO (BOTÕES) =====================
  def mark_as_read!
    update!(status: :lido) unless lido?
  end

  def mark_as_important!
    update!(status: :importante) unless importante?
  end

  # === MÉTODOS AUXILIARES ==========================
  def short_preview(limit = 40)
    content.to_s.truncate(limit)
  end

  def sender_label
    case sender_type
    when "Cliente"       then "Cliente"
    when "Transportador" then "Transportador"
    when "AdminUser"     then "Admin"
    else
      sender_type.to_s
    end
  end

  # === VISUALIZAÇÃO AMIGÁVEL ========================
  def to_s
    "[#{created_at.strftime('%d/%m %H:%M')}] #{sender_label}: #{short_preview}"
  end

  private

  # === SANITIZAÇÃO DO CONTEÚDO ======================
  # Usa o serviço ChatFilters::Sanitizer para bloquear telefones,
  # e-mails, links, CPF/CNPJ e palavras como 'zap', 'whatsapp', etc.
  def sanitize_content
    self.content = ChatFilters::Sanitizer.call(content)
  end
end
