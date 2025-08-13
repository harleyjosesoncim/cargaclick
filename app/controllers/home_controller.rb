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
      # app/controllers/home_controller.rb
class HomeController < ApplicationController
  def index
    # Ajuste o tempo conforme sua página (se for dinâmica, use menos)
    expires_in 5.minutes, public: true
  end
end

    ]

    @modal_sorteado = @modais.sample
  end
end

