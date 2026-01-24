# frozen_string_literal: true

class Clientes::BaseController < ApplicationController
  before_action :authenticate_cliente!
end
