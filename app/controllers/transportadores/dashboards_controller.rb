# frozen_string_literal: true

module Transportadores
  class DashboardsController < ApplicationController
    before_action :authenticate_transportador!

    # GET /transportadores/dashboard
    def index
      @transportador = current_transportador

      # ================================
      # STATUS DO PERFIL
      # ================================
      @perfil_completo = perfil_completo?(@transportador)
      @alerta_perfil   = !@perfil_completo

      # ================================
      # FRETES DISPONÍVEIS (POR CEP)
      # ================================
      @fretes = buscar_fretes_disponiveis(@transportador)

      # ================================
      # GANHOS (PLACEHOLDER SEGURO)
      # ================================
      @ganhos_total = 0
      @fretes_realizados = 0
    end

    private

    # -----------------------------------------------------
    # PERFIL COMPLETO?
    # -----------------------------------------------------
    def perfil_completo?(transportador)
      transportador.cep.present? &&
        transportador.pix_key.present? &&
        transportador.tipo_veiculo.present?
    end

    # -----------------------------------------------------
    # BUSCA DE FRETES (DEFENSIVA)
    # -----------------------------------------------------
    def buscar_fretes_disponiveis(transportador)
      return Frete.none unless transportador.cep.present?

      Frete
        .where(status: "disponivel")
        .where(origem_cep: transportador.cep)
        .order(created_at: :desc)
        .limit(5)
    rescue StandardError => e
      Rails.logger.error(
        "[DashboardsController] Erro ao buscar fretes: #{e.message}"
      )
      Frete.none
    end
  end
end
