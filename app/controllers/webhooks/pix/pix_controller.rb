def processar_evento(data)
  pix = data["pix"]&.first
  return unless pix

  txid = pix["txid"]
  return if txid.blank?

  frete = Frete.find_by(pix_txid: txid)

  unless frete
    Rails.logger.warn("[WEBHOOK PIX EFI] Frete não encontrado para txid=#{txid}")
    return
  end

  return if frete.status_pagamento == "pago"

  Rails.logger.info("[WEBHOOK PIX EFI] Frete ##{frete.id} encontrado. Marcando como pago.")

  frete.update!(
    status_pagamento: "pago"
  )
end
