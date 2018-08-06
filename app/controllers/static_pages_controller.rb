class StaticPagesController < ApplicationController
  before_action :authenticate_user!

  def main
  end

  def service
  end

  def misc
  end
end
