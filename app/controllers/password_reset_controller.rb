class PasswordResetController < ApplicationController
  # before_action :ensure_user_not_signed_in
  before_action :load_user, only: [ :edit, :reset ]
  before_action :set_user, only: :create

  def new
  end

  def create
    PasswordMailer.reset(@user).deliver_later
    redirect_to login_url, notice: t('controllers.password_reset.create.success')
  end

  def reset
    if @user.update(password_reset_params)
      redirect_to login_url, notice: t('controllers.password_reset.reset.success')
    else
      redirect_to edit_password_reset_url(params[:token]), notice: t('controllers.password_reset.reset.failure')
    end
  end

  def edit
  end

  private def load_user
    @user = User.find_by_password_reset_token(params[:token])
    redirect_to login_url, notice: t('controllers.password_reset.load_user.failure') unless @user
  end

  private def set_user
    @user = User.find_by_lower_email(params[:email])
    redirect_to new_password_reset_url, notice: t('controllers.password_reset.set_user.failure') unless @user
  end

  private def password_reset_params
    params.permit(:password, :password_confirmation)
  end
end
