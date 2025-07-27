class HomeController < ApplicationController
  def index
    @modais = [
      { nome: "Caminhão", emoji: "🚚" },
      { nome: "Bike", emoji: "🚴‍♂️" },
      { nome: "Moto", emoji: "🛵" },
      { nome: "A pé", emoji: "🦶" },
      { nome: "Patinete", emoji: "🛴" },
      { nome: "Barco", emoji: "🚤" },
      { nome: "Helicóptero", emoji: "🚁" },
      { nome: "Tartaruga", emoji: "🐢" }
    ]

    @modal_sorteado = @modais.sample
  end
end

