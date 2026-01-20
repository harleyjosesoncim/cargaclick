# frozen_string_literal: true

class ComissaoCampaign
  def self.ativa?
    ENV["CARGACLICK_CAMPANHA_TAXA"] == "true"
  end

  def self.percentual_promocional
    ENV.fetch("CARGACLICK_TAXA_PROMO", "6").to_f
  end
end
