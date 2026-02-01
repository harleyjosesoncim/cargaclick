# frozen_string_literal: true

module Transportadores
  class LandingController < ApplicationController
    layout "application"

    # Landing pública — NÃO exige login
    def index
    end
  end
end
