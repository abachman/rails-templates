class UserSessionsController < ApplicationController
  before_filter :require_user, :only => :destroy
  skip_before_filter :verify_authenticity_token, :only => [:new, :create]

  # GET /login
  def new
    @user_session = UserSession.new
  end

  # POST /user_session
  def create
    @user_session = UserSession.new(params[:user_session])
    if @user_session.save
      flash[:notice] = "Login successful!"
      redirect_back_or_default root_url
    else
      render :action => :new
    end
  end

  # GET /logout
  def destroy
    current_user_session.destroy
    flash[:notice] = "Logout successful!"
    redirect_to login_url
  end
end
