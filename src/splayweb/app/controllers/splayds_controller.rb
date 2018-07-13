class SplaydsController < ApplicationController

  def show
    @splayd = Splayd.find(params[:id])
  end

  def index
    @splayds = Splayd.all
  end
end