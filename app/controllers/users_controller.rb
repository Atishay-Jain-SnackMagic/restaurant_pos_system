class UsersController < ApplicationController
  before_action :ensure_not_currently_logged_in, only: [ :new, :create ]
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        send_verification_mail_to_user(@user)
        format.html { redirect_to_login_with_notice("Please verify you mail by clicking on link sent to your mail and login again") }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  private def user_params
    params.expect(user: [ :name, :email, :password, :password_confirmation ])
  end
end
