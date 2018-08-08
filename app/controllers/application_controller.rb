class ApplicationController < ActionController::Base

  before_action :set_up_output

  def set_up_output
    @output = {}
  end
end
