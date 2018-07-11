class SplaydsController < ApplicationController
  def index
    @splayds = Splayd.all
  end
end