class RegistrationController < ApplicationController
  before_action :ensure_not_currently_logged_in, only: [ :new, :create ]

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to login_url, notice: t('controllers.registration.save.success')
    else
      render :new, status: :unprocessable_entity
    end
  end

  private def user_params
    params.expect(user: [ :name, :email, :password, :password_confirmation ])
  end
end
