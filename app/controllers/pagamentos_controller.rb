# frozen_string_literal: true

class PagamentosController < ApplicationController
  # Controller legado mantido apenas para compatibilidade.
  # Fluxo oficial de pagamento é tratado por serviços (Escrow / PIX).

  def index
    head :not_found
  end
end
