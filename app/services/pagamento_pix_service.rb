# frozen_string_literal: true

# ⚠️ SERVICE DESATIVADO DEFINITIVAMENTE
#
# O fluxo de pagamento via Mercado Pago (PagamentoPixService)
# foi substituído por Efi::PixPayoutService.
#
# Este arquivo existe APENAS para evitar erro de autoload
# em código legado ainda referenciado (views/controllers antigos).
#
# ❌ NÃO UTILIZAR
# ❌ NÃO REATIVAR
# ✅ Fluxo oficial: Efi::PixPayoutService

class PagamentoPixService
  def initialize(*)
    raise RuntimeError, "PagamentoPixService DESATIVADO. Use Efi::PixPayoutService."
  end

  def method_missing(*)
    raise RuntimeError, "PagamentoPixService DESATIVADO. Use Efi::PixPayoutService."
  end

  def respond_to_missing?(*)
    true
  end
end
