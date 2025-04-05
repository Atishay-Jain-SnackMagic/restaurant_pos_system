class UsersController < ApplicationController
  before_action :ensure_not_currently_logged_in, only: [ :new, :create ]
  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        save_user_in_cookie(@user, params[:user][:remember_me])
        format.html { redirect_to root_path }
      else
        format.html { render :new, status: :unprocessable_entity }
      end
    end
  end

  private def user_params
    params.expect(user: [ :name, :email, :password, :password_confirmation ])
  end
end
