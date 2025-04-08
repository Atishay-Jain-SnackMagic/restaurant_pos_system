class ApplicationController < ActionController::Base
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  helper_method :current_user

  private def ensure_not_currently_logged_in
    redirect_to(root_path, notice: t("controllers.application.already_logged_in")) if current_user
  end

  private def current_user
    @current_user ||= User.find(session[:user_id]) if session[:user_id]
  end
end
