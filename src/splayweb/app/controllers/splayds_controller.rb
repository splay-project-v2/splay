class SplaydsController < ApplicationController

  def show
    @splayd = Splayd.find(params[:id])
  end

  def index
    @splayds = Splayd.all
  end

  def destroy
    splayd = Splayd.find(params[:id])
    if splayd.update(status: 'DELETED')
      flash[:notice] = 'Splayd was successfully deleted.'
      redirect_to action: 'index'
    else
      flash[:alert] = 'Problem deleting splayd.'
      redirect_to action: 'show', id: splayd
    end
  end

end