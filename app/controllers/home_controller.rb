# app/controllers/home_controller.rb
class HomeController < ApplicationController
  # Lista única e imutável de modais
  MODAIS = [
    { nome: 'Caminhão',    emoji: '🚚' },
    { nome: 'Bike',        emoji: '🚴‍♂️' },
    { nome: 'Moto',        emoji: '🛵' },
    { nome: 'A pé',        emoji: '🦶' },
    { nome: 'Patinete',    emoji: '🛴' },
    { nome: 'Barco',       emoji: '🚤' },
    { nome: 'Helicóptero', emoji: '🚁' },
    { nome: 'Tartaruga',   emoji: '🐢' }
  ].map(&:freeze).freeze

  def index
    # Só define cache se estiver habilitado (evita problemas em dev/test)
    expires_in 5.minutes, public: true if perform_caching

    @modais = MODAIS
    @modal_sorteado = pick_modal

    respond_to do |format|
      format.html
      format.json { render json: { modais: @modais, sorteado: @modal_sorteado } }
    end
  end

  private

  def pick_modal
    MODAIS.sample || { nome: 'Caminhão', emoji: '🚚' }
  end
end

