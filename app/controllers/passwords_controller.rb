class PasswordsController < ApplicationController
  before_action :ensure_not_currently_logged_in
  before_action :load_user_from_token, only: [ :edit, :update ]
  before_action :load_user_from_email, only: :create

  def new
  end

  def create
    PasswordMailer.reset(@user).deliver_later
    redirect_to login_url, notice: t('controllers.passwords.create.success')
  end

  def update
    if @user.update(password_params)
      redirect_to login_url, notice: t('controllers.passwords.update.success')
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def edit
  end

  private def load_user_from_token
    @user = User.find_by_password_reset_token(params[:token])
    unless @user
      flash[:error] = t('controllers.passwords.load_user_from_token.failure')
      redirect_to login_url
    end
  end

  private def load_user_from_email
    @user = User.find_by_lower_email(params[:email])
    unless @user
      flash[:error] = t('controllers.passwords.load_user_from_email.failure')
      redirect_to new_password_url
    end
  end

  private def password_params
    params.permit(:password, :password_confirmation)
  end
end
