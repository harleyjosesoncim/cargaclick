# frozen_string_literal: true

class Transportadores::BaseController < ApplicationController
  before_action :authenticate_transportador!
end

