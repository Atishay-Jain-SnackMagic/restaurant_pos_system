class SessionsController < ApplicationController
  before_action :ensure_not_currently_logged_in, only: [ :new, :create ]
  before_action :ensure_user_logged_in, only: :destroy
  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      save_user_in_session(user)
      redirect_to root_path
    else
      redirect_to login_url, notice: "Invalid email/password combination"
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: "Logged out"
  end

  private def ensure_user_logged_in
    redirect_back_or_to(root_path, notice: "No user is logged in") unless session[:user_id]
  end
end
