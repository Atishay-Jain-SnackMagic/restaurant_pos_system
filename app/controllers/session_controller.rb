class SessionController < ApplicationController
  before_action :ensure_not_currently_logged_in, only: [ :new, :create ]
  before_action :ensure_user_logged_in, only: :destroy
  before_action :load_user, only: :create

  def new
  end

  def create
    if @user.authenticate(params[:password])
      if @user.verified_at?
        session[:user_id] = @user.id
        redirect_to meals_path, notice: t('controllers.session.login.success')
      else
        send_verification_mail_to_user(@user)
        redirect_to_login_with_notice(t('controllers.session.verification.failure'))
      end
    else
      redirect_to_login_with_notice(t('controllers.session.authentication.failure'))
    end
  end

  def destroy
    session[:user_id] = nil
    redirect_to root_path, notice: t('controllers.session.log_out.success')
  end

  private def ensure_user_logged_in
    redirect_back_or_to(root_path, notice: 'controllers.session.log_out.failure') unless current_user
  end

  private def load_user
    @user = User.find_by_email(params[:email])
    redirect_to_login_with_notice(t('controllers.session.login.user_not_found')) unless @user
  end
end
