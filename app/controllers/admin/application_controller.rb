class Admin::ApplicationController < ApplicationController
  before_action :ensure_user_logged_in
  before_action :authorize

  private def ensure_user_logged_in
    redirect_back_or_to root_path, notice: t('controllers.admin.application.login.failure') unless current_user
  end

  private def authorize
    redirect_back_or_to root_path, notice: t('controllers.admin.application.authorize.failure') unless current_user.is_admin?
  end
end
