class UsersController < ApplicationController
  before_action :require_anonymous, only: [:new, :create]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
    if @user.save
      flash[:success] = 'Account is created!'
      redirect_to controller: 'home', method: 'get'
    else
      flash[:alert] = 'An error occured'
      render 'new'
    end
  end

  private
  def user_params
    params.require(:user).permit(:login, :email, :password, :password_confirmation)
  end
end