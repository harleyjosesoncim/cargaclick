# frozen_string_literal: true
module Clientes
  class RegistrationsController < Devise::RegistrationsController
    before_action :configure_permitted_parameters

    protected

    def configure_permitted_parameters
      devise_parameter_sanitizer.permit(:sign_up, keys: [:nome])
    end
  end
end
