# app/controllers/landing_controller.rb
class LandingController < ApplicationController
  # Se no ApplicationController tiver isso:
  # before_action :authenticate_cliente!
  # before_action :authenticate_transportador!
  # before_action :authenticate_user!

  # então aqui você libera a landing:
  skip_before_action :authenticate_cliente!,     only: [:index], raise: false
  skip_before_action :authenticate_transportador!, only: [:index], raise: false
  skip_before_action :authenticate_user!,        only: [:index], raise: false

  def index
  end
end
