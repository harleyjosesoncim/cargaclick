class ApplicationController < ActionController::Base
  def after_sign_up_path_for(resource)
    fretes_path # ou root_path, dashboard_path etc.
  end

  def after_sign_in_path_for(resource)
    fretes_path
  end
end
