class UsersController < ApplicationController
  before_action :load_user_from_token, only: [ :verify_email ]
  before_action :load_user_from_email, only: [ :resend_verification_email ]
  before_action :ensure_user_not_verified, only: [ :verify_email, :resend_verification_email ]

  def verify_email
    @user.verify
    redirect_to login_url, notice: t('controllers.users.verify_email.success')
  end

  def request_verification_email
  end

  def resend_verification_email
    @user.send_verification_mail
    redirect_to login_url, notice: t('controllers.users.resend_verification_email.success')
  end

  private def ensure_user_not_verified
    redirect_to login_url, notice: t('controllers.users.not_verified.failure') if @user.verified_at?
  end

  private def load_user_from_token
    @user = User.find_by_token_for(:email_verification, params[:token])
    redirect_to new_verification_email_url, notice: t('controllers.users.load_from_token.failure') unless @user
  end

  private def load_user_from_email
    @user = User.find_by_lower_email(params[:email])
    redirect_to new_verification_email_url, notice: t('controllers.users.load_from_email.failure') unless @user
  end
end
