class MigracaoController < ApplicationController
  skip_before_action :authenticate_scope!, raise: false

  def discord
  end
end
