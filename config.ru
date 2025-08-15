# config.ru
# frozen_string_literal: true
require_relative "config/environment"

run Rails.application
Rails.application.load_server
# This file is used by Rack-based servers to start the application.
# It is recommended to use `rails server` or `bin/rails server` instead of
# running this file directly.       