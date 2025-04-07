class SessionsController < ApplicationController
  before_action :ensure_not_currently_logged_in, only: [ :new, :create ]
  before_action :ensure_user_logged_in, only: :destroy
  def new
  end

  def create
    user = User.find_by(email: params[:email])
    if user&.authenticate(params[:password])
      unless user.verified?
        send_verification_mail_to_user(user)
        redirect_to_login_with_notice("Verification email sent again. Please verify first")
      else
        save_user_in_cookie(user, params[:remember_me])
        redirect_to root_path, notice: "Logged in successfully"
      end
    else
      redirect_to_login_with_notice("Invalid email/password combination")
    end
  end

  def destroy
    cookies.delete :user_id
    redirect_to root_path, notice: "Logged out"
  end

  private def ensure_user_logged_in
    redirect_back_or_to(root_path, notice: "No user is logged in") unless cookies.signed[:user_id]
  end
end
