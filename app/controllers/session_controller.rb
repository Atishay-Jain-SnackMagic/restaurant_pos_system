class SessionController < ApplicationController
  before_action :ensure_not_currently_logged_in, only: [ :new, :create ]
  before_action :ensure_user_logged_in, only: :destroy
  before_action :set_and_check_valid_user, :authenticate_user, only: :create

  def new
  end

  def create
    save_user_in_session
    redirect_to meals_path
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: t('controllers.session.log_out.success')
  end

  private def save_user_in_session
    session[:user_id] = @user.id
  end

  private def ensure_user_logged_in
    redirect_back_or_to(root_path, notice: 'controllers.session.log_out.failure') unless session[:user_id]
  end

  private def set_and_check_valid_user
    @user = User.find_by("LOWER(email) = ?", params[:email].downcase)
    redirect_to login_url, notice: t('controllers.session.login.user_not_found') unless @user
  end

  private def authenticate_user
    redirect_to login_url, notice: t('controllers.session.authentication.fail') unless @user.authenticate(params[:password])
  end
end
