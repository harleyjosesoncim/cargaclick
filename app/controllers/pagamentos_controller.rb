# frozen_string_literal: true

class PagamentoPixService
  Result = Struct.new(:success?, :data, :error)

  def initialize
    @sdk = MercadoPago::SDK.new(ENV.fetch("MERCADO_PAGO_ACCESS_TOKEN"))
    @payment = @sdk.payment
  end

  # =====================================================
  # CHECKOUT PF (PIX padrão)
  # =====================================================
  def checkout_pf(frete, cliente, transportador, pagamento)
    criar_pix!(
      frete: frete,
      cliente: cliente,
      pagamento: pagamento,
      tipo: :pf
    )
  end

  # =====================================================
  # CHECKOUT AVULSO
  # =====================================================
  def checkout_avulso(frete, cliente, transportador, pagamento)
    criar_pix!(
      frete: frete,
      cliente: cliente,
      pagamento: pagamento,
      tipo: :avulso
    )
  end

  # =====================================================
  # CHECKOUT ASSINANTE (sem taxa)
  # =====================================================
  def checkout_assinante(frete, cliente, transportador, pagamento)
    criar_pix!(
      frete: frete,
      cliente: cliente,
      pagamento: pagamento,
      tipo: :assinante,
      taxa_plataforma: 0.0
    )
  end

  # =====================================================
  # WEBHOOK
  # =====================================================
  def webhook(params)
    payment_id = params.dig("data", "id")
    return unless payment_id

    response = @payment.get(payment_id)
    return unless response["status"]

    pagamento = Pagamento.find_by(
      external_reference: response["external_reference"]
    )
    return unless pagamento

    pagamento.update!(
      status: map_status(response["status"]),
      mp_payment_id: payment_id,
      pago_em: Time.current
    )
  end

  # =====================================================
  # CALLBACK LEGADO (fallback)
  # =====================================================
  def retorno(params)
    webhook(params)
  end

  # =====================================================
  # PRIVATE
  # =====================================================
  private

  def criar_pix!(frete:, cliente:, pagamento:, tipo:, taxa_plataforma: 0.08)
    valor = pagamento.valor_total.to_f
    taxa  = (valor * taxa_plataforma).round(2)

    payload = {
      transaction_amount: valor,
      description: "Frete ##{frete.id} - CargaClick",
      payment_method_id: "pix",
      external_reference: "frete_#{frete.id}_pag_#{pagamento.id}",
      payer: {
        email: cliente.email || "cliente@cargaclick.com.br",
        first_name: cliente.try(:nome) || "Cliente",
        identification: {
          type: "CPF",
          number: cliente.try(:cpf).to_s.gsub(/\D/, "")
        }
      }
    }

    payload[:application_fee] = taxa if taxa.positive?

    response = @payment.create(payload)

    unless response["status"] == "pending"
      return Result.new(false, nil, response["message"] || "Falha ao criar PIX")
    end

    qr = response.dig("point_of_interaction", "transaction_data")

    pagamento.update!(
      status: "pendente",
      external_reference: payload[:external_reference],
      mp_payment_id: response["id"],
      pix_qr_code: qr["qr_code"],
      pix_qr_code_base64: qr["qr_code_base64"],
      comissao_cargaclick: taxa,
      valor_liquido: valor - taxa
    )

    Result.new(true, {
      qr_code: qr["qr_code"],
      qr_code_base64: qr["qr_code_base64"],
      status: "pendente",
      valor: valor
    }, nil)
  rescue => e
    Rails.logger.error("[PIX][MP] #{e.class} - #{e.message}")
    Result.new(false, nil, "Erro interno ao gerar PIX")
  end

  def map_status(mp_status)
    case mp_status
    when "approved" then "confirmado"
    when "cancelled" then "cancelado"
    when "refunded" then "estornado"
    else "pendente"
    end
  end
end
