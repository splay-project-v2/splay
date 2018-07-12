class JobsController < ApplicationController
  def index
    @jobs = Job.all
  end

  def destroy
    job = Job.find(params[:id])
    if job.update(command: 'KILL')
      flash[:notice] = 'Job was killed.'
    else
      flash[:alert] = 'Problem killing job.'
    end
    redirect_to action: 'index'
  end
end