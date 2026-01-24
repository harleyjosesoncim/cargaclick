# frozen_string_literal: true

class Admin::BaseController < ApplicationController
  before_action :authenticate_admin_user!
end
