class Admin::ApplicationController < ApplicationController
  before_action :authorize

  private def authorize
    redirect_back_or_to root_path, notice: t('controllers.admin.application.authorize.failure') unless current_user&.is_admin?
  end
end
