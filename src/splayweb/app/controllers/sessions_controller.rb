class SessionsController < ApplicationController
  before_action :require_login, only: [:destroy]

  def destroy
    self.current_user.forget_me if logged_in?
    cookies.delete :auth_token
    reset_session
    flash[:notice] = "You have been logged out."
    redirect_to home_index_path
  end

end