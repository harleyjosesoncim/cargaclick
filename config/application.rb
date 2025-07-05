require_relative "boot"

require "rails/all"

Bundler.require(*Rails.groups)

module Cargaclick
  class Application < Rails::Application
    config.load_defaults 7.1
    config.time_zone = "Brasilia"
  end
end
