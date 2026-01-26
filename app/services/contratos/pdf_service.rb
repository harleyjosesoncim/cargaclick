
require "prawn"

module Contratos
  class PdfService
    def self.gerar(contrato)
      path = Rails.root.join("tmp", "contrato_\#{contrato.id}.pdf")
      Prawn::Document.generate(path) do |pdf|
        pdf.text "Contrato Digital", size: 18, style: :bold
        pdf.move_down 20
        pdf.text contrato.conteudo
        pdf.move_down 20
        pdf.text "Hash: \#{contrato.hash_documento}"
        pdf.text "Aceito em: \#{contrato.aceito_em}"
      end
      path
    end
  end
end
