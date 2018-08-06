class StaticPagesController < ApplicationController
  before_action :authenticate_user!, except: :main

  def main
  end

  def service
  end

  def misc
  end
end
